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

    wxProtocol *_link;

    if (uri->GetScheme() == "https") {
        CurlingHTTPS *link;

        _link = link = new CurlingHTTPS();

        link->Connect(uri->GetServer(), 443);

        return link->GetInputStream(getPathRqFromURI(uri));
    } else {
        wxHTTP *link;

        _link = link = new wxHTTP();

        link->Connect(uri->GetServer(), 80);

        return link->GetInputStream(getPathRqFromURI(uri));
    }
}

int
curling_readURL(const char *url, char *buf, int len)
{
    wxURI *uri = new wxURI(url);

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
