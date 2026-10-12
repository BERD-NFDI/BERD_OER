# Helpers for materials.csv
# materials.csv is the single source of truth for all materials.
# Multiple values in one cell are separated by ";".

read_materials <- function(csv_file = "materials.csv") {
  read.csv(csv_file, check.names = FALSE, colClasses = "character",
           na.strings = character(0), fileEncoding = "UTF-8")
}

split_values <- function(x) {
  values <- trimws(unlist(strsplit(x, ";", fixed = TRUE)))
  values[values != ""]
}

render_tags <- function(section_id, csv_file = "../materials.csv") {
  materials <- read_materials(csv_file)
  row <- materials[materials$ID == section_id, ]
  if (nrow(row) == 0) {
    stop(sprintf("render_tags(): ID '%s' not found in materials.csv", section_id))
  }

  make_spans <- function(tags, class) {
    paste(sprintf("<span class=\"tag tag-%s\"># %s</span>", class, tags),
          collapse = " ")
  }

  cat(
    make_spans(split_values(row$data), "data"), " ",
    make_spans(split_values(row$type), "type"), " ",
    make_spans(split_values(row$name), "name"), " ",
    make_spans(split_values(row$year), "year"), " ",
    make_spans(split_values(row$material), "material"),
    "\n"
  )
}

# Turns a location like "03_ml/01_dl.qmd#Methods-DL" into links for the
# overview table: the page title (Topic) and the section heading (Section).
location_links <- function(location, root = ".") {
  page <- sub("#.*$", "", location)
  anchor <- if (grepl("#", location)) sub("^[^#]*#", "", location) else ""
  lines <- readLines(file.path(root, page), warn = FALSE, encoding = "UTF-8")
  href <- sub("\\.qmd$", ".html", page)

  title_line <- grep("^title:", lines, value = TRUE)[1]
  title <- if (is.na(title_line)) page else
    gsub("^title:\\s*[\"']?|[\"']?\\s*$", "", title_line)
  topic <- sprintf("<a href='%s'>%s</a>", href, title)

  if (anchor == "") {
    return(list(topic = topic, section = topic))
  }
  heading <- grep(sprintf("\\{#%s[ }]", anchor), lines, value = TRUE)[1]
  heading <- trimws(gsub("^#+|\\{.*\\}", "", heading))
  section <- sprintf("<a href='%s#%s'>%s</a>", href, anchor, heading)
  list(topic = topic, section = section)
}
