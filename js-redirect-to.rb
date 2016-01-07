def js_redirect_to(path)
    render js: %(window.location.href='#{path}') and return
end