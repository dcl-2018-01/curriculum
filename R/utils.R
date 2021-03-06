read_yaml <- function(path) {
  tryCatch(
    yaml::yaml.load_file(path),
    error = function(e) {
      stop(
        "Problem loading ", path, "\n",
        e$message,
        call. = FALSE)
    }
  )
}

load_units <- function() {
  paths <- dir(here::here("units"), pattern = "\\.yml$", full.names = TRUE)
  names(paths) <- tools::file_path_sans_ext(basename(paths))

  map(paths, read_yaml)
}

load_syllabus <- function() {
  read_yaml(here::here("syllabus.yml"))
}

load_supplements <- function() {
  x <- read_yaml(here::here("supplements.yml"))
  set_names(x, map_chr(x, "slug"))
}

themes <- c("Explore", "Wrangle", "Program", "Model", "Communicate", "Workflow")


has_name <- function(x, nm) {
  if (is.null(names(x)))
    return(FALSE)

  nm %in% names(x)
}

`%||%` <- function(x, y) if (is.null(x)) y else x

find_book <- function(x) {
  match <- books$id == x
  if (!any(match)) {
    stop("Couldn't find book: '", x, "'", call. = FALSE)
  }

  as.list(books[match, , drop = FALSE])
}

indent <- function(text, by = 2, first = by, wrap = FALSE) {
  if (wrap) {
    wrapped <- strwrap(text, width = 80, indent = first, exdent = by)
    paste0(wrapped, "\n", collapse = "")
  } else {
    paste(strrep(" ", first), gsub("\n", paste0("\n", strrep(" ", by)), text))
  }
}

mtime <- function(x) {
  max(file.info(x)$mtime)
}

out_of_date <- function(src, dest) {
  if (!file.exists(dest))
    return(TRUE)

  mtime(src) > mtime(dest)
}
