#import "/.calepin/calepin.typ" as calepin

#set document(title: [Page not found])

#metadata((
  title: "Page not found",
  summary: "The requested page does not exist.",
)) <website-metadata>

= Page not found

The page you asked for does not exist. It may have moved, or the link that
brought you here may be out of date.

// A host serves this page under whatever URL was requested, so its links have
// to be written from the site root rather than relative to the current page.
- #link(calepin.url("/index.html"))[Home]
- #link(calepin.url("/reference/r/index.html"))[R reference]
- #link(calepin.url("/reference/python/index.html"))[Python reference]
- #link("https://github.com/vincentarelbundock/countrycode")[Source on GitHub]
