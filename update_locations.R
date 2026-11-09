# Fills the "location (auto)" column of materials.csv.
#
# Scans all .qmd pages for render_tags("ID") calls and records where each
# material is embedded: page plus the nearest heading above it that has an
# {#anchor}, e.g. "03_ml/01_dl.qmd#Methods-DL".
# Calls inside HTML comments (<!-- -->) or commented-out R lines are ignored.
#
# Runs automatically before every render/preview (pre-render in _quarto.yml).
# Can also be run by hand from the project folder: Rscript update_locations.R

source("utils.R")

csv_file <- "materials.csv"
location_col <- "location (auto)"

materials <- read_materials(csv_file)

# --- Check the table -------------------------------------------------------
required <- c("ID", "name", "url", "type", "data", "year", "material",
              "notes", location_col)
missing_cols <- setdiff(required, names(materials))
if (length(missing_cols) > 0) {
  stop("materials.csv: missing columns: ", paste(missing_cols, collapse = ", "),
       "\nWas the file saved with ';' instead of ',' as separator (e.g. by Excel)?")
}
if (any(trimws(materials$ID) == "")) {
  stop("materials.csv: some rows have an empty ID")
}
dupes <- unique(materials$ID[duplicated(materials$ID)])
if (length(dupes) > 0) {
  stop("materials.csv: duplicate IDs: ", paste(dupes, collapse = ", "))
}

# --- Find render_tags() calls in all pages ---------------------------------
qmd_files <- list.files(".", pattern = "\\.qmd$", recursive = TRUE)
qmd_files <- qmd_files[!grepl("^(_site|\\.quarto)/", qmd_files)]

strip_html_comments <- function(lines) {
  text <- paste(lines, collapse = "\n")
  comments <- gregexpr("(?s)<!--.*?-->", text, perl = TRUE)
  # keep the line breaks so line numbers stay the same
  regmatches(text, comments) <- lapply(regmatches(text, comments),
                                       function(m) gsub("[^\n]", "", m))
  strsplit(text, "\n", fixed = TRUE)[[1]]
}

found <- data.frame(ID = character(0), location = character(0),
                    where = character(0))

for (file in qmd_files) {
  lines <- strip_html_comments(readLines(file, warn = FALSE, encoding = "UTF-8"))
  anchor <- ""
  for (i in seq_along(lines)) {
    heading <- regmatches(lines[i],
                          regexec("^#{1,6}\\s.*\\{#([^ }]+)", lines[i], perl = TRUE))[[1]]
    if (length(heading) > 0) anchor <- heading[2]

    call <- regmatches(lines[i],
                       regexec("^\\s*render_tags\\(\"([^\"]+)\"", lines[i], perl = TRUE))[[1]]
    if (length(call) > 0) {
      location <- if (anchor == "") file else paste0(file, "#", anchor)
      if (anchor == "") {
        message(sprintf("Note: %s:%d render_tags(\"%s\") has no heading with an {#anchor} above it - location is the page only",
                        file, i, call[2]))
      }
      found <- rbind(found, data.frame(ID = call[2], location = location,
                                       where = sprintf("%s:%d", file, i)))
    }
  }
}

# --- IDs used on pages but missing in the table ----------------------------
unknown <- found[!found$ID %in% materials$ID, ]
if (nrow(unknown) > 0) {
  stop("render_tags() uses IDs that are not in materials.csv:\n",
       paste(sprintf("  %s  (%s)", unknown$ID, unknown$where), collapse = "\n"))
}

# --- Write locations --------------------------------------------------------
new_locations <- vapply(materials$ID, function(id) {
  paste(sort(unique(found$location[found$ID == id])), collapse = "; ")
}, character(1), USE.NAMES = FALSE)

if (!identical(new_locations, materials[[location_col]])) {
  materials[[location_col]] <- new_locations
  write.csv(materials, csv_file, row.names = FALSE, na = "",
            fileEncoding = "UTF-8")
  message("materials.csv: locations updated")
}

not_embedded <- materials$ID[new_locations == ""]
message(sprintf("%d of %d materials are on the website.",
                nrow(materials) - length(not_embedded), nrow(materials)))
if (length(not_embedded) > 0) {
  message("Not on the website yet: ", paste(not_embedded, collapse = ", "))
}
