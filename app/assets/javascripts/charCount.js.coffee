$(document).ready ->
  pluralize_characters = (num) ->
    if num == 1
      return num + " character"
    else
      return num + " characters"

  $("#content").keyup ->
    chars = $("#content").val().length
    max_length = 140
    left = max_length - chars
    if left >= 0
      $("#char_count").text(pluralize_characters(left) + " left")
    else
      left = left * (-1)
      $("#char_count").text(pluralize_characters(left) + " too long")