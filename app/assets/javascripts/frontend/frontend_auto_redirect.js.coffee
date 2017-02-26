$ ->
  if $('body.frontend_homepage_show').length > 0
    ref = document.referrer
    re = /http:\/\/tech.mit.edu\/V(\d+)\/N(\d+)\/(.*)/
    res = re.exec(ref)

    if res
      v = parseInt(res[1])
      n = parseInt(res[2])
      r = res[3]

      if v >= 127 && (v != 135 || n <= 8)
        url = '/V' + v + '/N' + n + '/' + r
        document.location = url
