library(markdown)
#set working directory to the directory of the file
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Function to extract topic from markdown filename
extract_topic_from_filename <- function(filename) {
  # Remove .md extension and replace underscores with spaces
  gsub("_", " ", gsub("\\.md$", "", basename(filename)))
}

# Function to add robots noindex meta tag
add_noindex_meta <- function(html_content) {
  gsub("<head>", '<head>\n <meta name="robots" content="noindex">', html_content)
}

# Read all markdown files from markdown_articles directory
markdown_files <- list.files("markdown_articles", pattern = "\\.md$", full.names = TRUE)
cat("Found", length(markdown_files), "markdown files\n")

# Extract topics from filenames
list_of_topics <- sapply(markdown_files, extract_topic_from_filename)
list_of_html_filenames <- gsub("\\.md$", ".html", basename(markdown_files))

# Read markdown content
list_of_markdown_articles <- sapply(markdown_files, readLines, warn = FALSE)
list_of_markdown_articles <- sapply(list_of_markdown_articles, paste, collapse = "\n")

# Add links to 5 random other articles for each article
for (i in seq_along(list_of_markdown_articles)) {
  # Get 5 random article indices (excluding current article)
  other_articles <- setdiff(seq_along(list_of_topics), i)
  if (length(other_articles) >= 5) {
    linked_article_ids <- sample(other_articles, 5)
  } else {
    linked_article_ids <- other_articles
  }
  
  # Create links to other articles
  linked_articles_strings <- sapply(linked_article_ids, function(id) {
    paste0("[", list_of_topics[id], "](", list_of_html_filenames[id], ")")
  })
  linked_articles_strings <- paste(linked_articles_strings, collapse = "  \n\n")
  linked_articles_strings <- paste0("## See also \n\n", linked_articles_strings)
  list_of_markdown_articles[i] <- paste0(list_of_markdown_articles[i], "\n\n", linked_articles_strings)
}

# Convert markdown articles to HTML
list_of_html_articles <- sapply(list_of_markdown_articles, markdown::markdownToHTML, stylesheet = "style.css", title = "")

# Add robots noindex meta tag to each HTML article
list_of_html_articles <- sapply(list_of_html_articles, add_noindex_meta)

# Create HTML directory structure
dir.create("html", showWarnings = FALSE)
dir.create("html/articles", showWarnings = FALSE)

# Write HTML articles to html/articles directory
for (i in seq_along(list_of_html_filenames)) {
  writeLines(list_of_html_articles[i], file.path("html/articles", list_of_html_filenames[i]))
}
cat("Generated", length(list_of_html_filenames), "HTML articles\n")


# Generate index.html
cat("Generating index.html...\n")
links <- paste0(sapply(seq_along(list_of_topics), function(id) {
  paste0("[", list_of_topics[id], "](articles/", list_of_html_filenames[id], ")")
}), collapse = "  \n")

index_md <- paste0("# Economics Articles  \n\n ## ", "Index", "\n\n", links)

# Convert index to HTML and add noindex meta tag
index_html <- markdown::markdownToHTML(index_md, stylesheet = "style.css", title = "")
index_html <- add_noindex_meta(index_html)

writeLines(index_html, "html/index.html")

cat("HTML generation complete! All files saved to html/ directory\n")


