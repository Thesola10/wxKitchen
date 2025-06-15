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


// Exports ahead!
extern "C" {

int
curling_readURL(const char *url, char *buf, int len)
{
    wxURI *uri = new wxURI(url);

    wxObject *_link;
    wxInputStream *conn;

    int reslen = -1;

    if (uri->GetScheme() == "https") {
        CurlingHTTPS *link;
        _link = link = new CurlingHTTPS();

        link->Connect(uri->GetServer(), 443);

        conn = link->GetInputStream(uri->GetPath());
    } else {
        wxHTTP *link;

        _link = link = new wxHTTP();

        link->Connect(uri->GetServer(), 80);

        conn = link->GetInputStream(uri->GetPath());
    }

    if (conn == NULL)
        return -1;

    reslen = conn->Read(buf, len).LastRead();

    delete conn;
    delete _link;

    return reslen;
}

}
// vim: ft=cpp.doxygen
