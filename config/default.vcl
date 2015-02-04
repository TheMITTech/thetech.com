vcl 4.0;

backend default {
  .host = "localhost";
  .port = "4000";
}

acl local {
  "localhost";
  "54.0.0.0"/8;
}

sub vcl_recv {
  if (req.url ~ "^/admin/" ||
      req.url ~ "^/admin") {
    return(pass);
  }

  if (req.method == "PURGE") {
    if (client.ip ~ local) {
      ban("obj.http.x-url ~ " + req.url);
      return(synth(200, "Banned. "));
    } else {
      return(synth(403, "Access denied."));
    }
  }

  unset req.http.Cache-Control;
  unset req.http.Max-Age;
  unset req.http.Pragma;
  unset req.http.Cookie;

  return(hash);
}

sub vcl_backend_response {
  set beresp.http.x-url = bereq.url;
  set beresp.http.x-host = bereq.http.host;
}

sub vcl_deliver {
  if (obj.hits > 0) {
    set resp.http.X-Cache = "HIT";
  } else {
    set resp.http.X-Cache = "MISS";
  }

  set resp.http.Cache-Control = "public, no-cache";
}


