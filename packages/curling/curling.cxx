/**
 * @file        curling.cxx
 * @author      Karim Vergnes <me@thesola.io>
 * @copyright   GPLv2
 * @brief       Simple HTTP+HTTPS request library
 *
 * Wraps together wxURL, wxSocketBase and Cryanc to achieve an easy-to-use
 * HTTP and HTTPS communication API, in a similar fashion to libcurl.
 */

#include "curling.h"

#include <wx/uri.h>

wxString
getPathRqFromURI(wxURI *uri)
{
    wxString prq = wxT("/");

    if (uri->HasPath())
        prq = uri->GetPath();
    if (uri->HasQuery()) {
        prq.append("?");
        prq.append(uri->GetQuery());
    }

    return prq;
}

// Exports ahead!
extern "C" {

wxInputStream *
curling_streamURL(const char *url)
{
    wxURI *uri = new wxURI(url);

    CurlingHTTPS *httpsLink = NULL;
    wxHTTP *httpLink = NULL;

    wxString scm = uri->GetScheme();

    if (scm == "https") {
        httpsLink = new CurlingHTTPS();

        httpsLink->Connect(uri->GetServer(), 443);

        return httpsLink->GetInputStream(getPathRqFromURI(uri));
    } else if (scm == "http") {
        httpLink = new wxHTTP();

        httpLink->Connect(uri->GetServer(), 80);

        return httpLink->GetInputStream(getPathRqFromURI(uri));
    } else {
        printf("Unsupported scheme: %s\n", scm.c_str());
        return NULL;
    }
}

int
curling_readURL(const char *url, char *buf, int len)
{
    wxInputStream *conn = curling_streamURL(url);

    int reslen = -1;

    if (conn == NULL)
        return -1;

    reslen = conn->Read(buf, len).LastRead();

    delete conn;

    return reslen;
}

}
// vim: ft=cpp.doxygen
