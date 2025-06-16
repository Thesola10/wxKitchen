/**
 * @file        curling.h
 * @author      Karim Vergnes <me@thesola.io>
 * @copyright   GPLv2
 * @brief       Simple HTTP+HTTPS request library
 *
 * Wraps together wxURL, wxSocketBase and Cryanc to achieve an easy-to-use
 * HTTP and HTTPS communication API, in a similar fashion to libcurl.
 */

#ifndef __CURLING_H
#define __CURLING_H

#include <cryanc.h>

#if __cplusplus

#include <wx/socket.h>
#include <wx/protocol/http.h>

#if !wxUSE_SOCKETS
# error "wxWidgets must be built with sockets support."
#endif

class CurlingTLSSocketClient : public wxSocketClient
{
public:
    CurlingTLSSocketClient(wxSocketFlags flags = wxSOCKET_NONE);
    ~CurlingTLSSocketClient();

    bool
    Connect(wxIPaddress& addr, bool wait = true);

    wxSocketBase&
    Read(void *buffer, wxUint32 nbytes) override;

    wxSocketBase&
    Write(const void *buffer, wxUint32 nbytes) override;

    bool Close() override;
private:
    wxSocketBase& Flush();

    struct TLSContext *ctx;
};

class CurlingHTTPS : public wxHTTP, public CurlingTLSSocketClient
{
protected:
    wxIPaddress *m_addr;
public:
    CurlingHTTPS();
    ~CurlingHTTPS();

    bool
    Connect(const wxString& host, unsigned short port);

    bool
    Connect(wxIPaddress& addr, bool wait = true);

    wxInputStream *
    GetInputStream(const wxString& path);

    bool Abort();

friend class CurlingHTTPSStream;

    DECLARE_DYNAMIC_CLASS(CurlingHTTPS)
    DECLARE_PROTOCOL(CurlingHTTPS)
};

extern "C" {
#else // !__cplusplus
#include <wxc.h>
#endif

wxInputStream *
curling_streamURL(const char *url);

int
curling_readURL(const char *url, char *buffer, int len);

#if __cplusplus
}
#endif

#endif //__CURLING_H

// vim: ft=cpp.doxygen
