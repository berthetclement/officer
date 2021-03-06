getncheck <- function(x, str){
  child_ <- xml_child(x, str)
  expect_false( inherits(child_, "xml_missing") )
  child_
}



test_that("seqfield add ", {
  x <- read_docx() %>%
    body_add_par("Time is: ", style = "Normal") %>%
    slip_in_seqfield(
      str = "TIME \u005C@ \"HH:mm:ss\" \u005C* MERGEFORMAT")

  node <- x$doc_obj$get_at_cursor()
  getncheck(node, "w:r/w:fldChar[@w:fldCharType='begin']")
  getncheck(node, "w:r/w:fldChar[@w:fldCharType='end']")

  child_ <- getncheck(node, "w:r/w:instrText")
  expect_equal( xml_text(child_), "TIME \\@ \"HH:mm:ss\" \\* MERGEFORMAT" )

  x <- body_add_par(x, " - This is a figure title", style = "centered") %>%
    slip_in_seqfield(str = "SEQ Figure \u005C* roman",
                     style = 'Default Paragraph Font', pos = "before") %>%
    slip_in_text("Figure: ", style = "strong", pos = "before")
  node <- x$doc_obj$get_at_cursor()
  expect_equal( xml_text(node), "Figure: SEQ Figure \\* roman - This is a figure title" )
})



test_that("hyperlink add ", {
  href_ <- "https://github.com/davidgohel"
  x <- read_docx() %>%
    body_add_par("Here is a link: ", style = "Normal") %>%
    slip_in_text(str = "the link", style = "strong", hyperlink = href_)

  rel_df <- x$doc_obj$rel_df()
  expect_true( href_  %in% rel_df$target )
  expect_equal( rel_df[ rel_df$target == href_, ]$target_mode, "External" )
  expect_match( rel_df[ rel_df$target == href_, ]$type, "^http://schemas(.*)hyperlink$" )

  node <- x$doc_obj$get_at_cursor()
  child_ <- getncheck(node, "w:hyperlink/w:r/w:t")
  expect_equal( xml_text(child_), "the link" )
})
