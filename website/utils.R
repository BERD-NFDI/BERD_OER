library(yaml)
library(dplyr)
library(purrr)

render_tags <- function(section_id, yaml_file = "../tags.yaml") {
  tags_data <- read_yaml(yaml_file)
  tags_section <- Filter(function(x) !is.null(x$ID) && x$ID == section_id, tags_data) # nolint

  make_spans <- function(tags, class) {
    sapply(tags, function(tag) {
      sprintf("<span class=\"tag tag-%s\"># %s</span>", class, tag)
    }) %>% paste(collapse = " ")
  }

  cat(
    make_spans(tags_section[[1]]$Data, "data"), " ",
    make_spans(tags_section[[1]]$Type, "type"), " ",
    make_spans(tags_section[[1]]$Name, "name"), " ",
    make_spans(tags_section[[1]]$Year, "year"), " ",
    make_spans(tags_section[[1]]$Material, "material"),
    "\n"
  )
}