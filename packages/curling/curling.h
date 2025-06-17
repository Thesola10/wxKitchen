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

    wxSocketBase&
    Discard() override;

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
    Connect(const wxString& host, unsigned short port) override;

    bool
    Connect(wxIPaddress& addr, bool wait = true);

    wxInputStream *
    GetInputStream(const wxString& path) override;

    wxSocketBase&
    Read(void *buffer, wxUint32 nbytes) override
    { return CurlingTLSSocketClient::Read(buffer, nbytes); }

    wxSocketBase&
    Write(const void *buffer, wxUint32 nbytes) override
    { return CurlingTLSSocketClient::Write(buffer, nbytes); }

    bool Abort() override;

friend class CurlingHTTPSStream;

    DECLARE_DYNAMIC_CLASS(CurlingHTTPS)
    DECLARE_PROTOCOL(CurlingHTTPS)
};

extern "C" {
#else // !__cplusplus
#include <wxc.h>
#endif

/**
 * @brief   Open a wxInputStream retrieving the body of an URL, using HTTP or HTTPS.
 *
 * @param url       The URL to open. Protocol must be HTTP or HTTPS.
 * @return A wxInputStream object from which the HTTP body can be obtained.
 */
wxInputStream *
curling_streamURL(const char *url);

/**
 * @brief   Open and read the first len bytes from an URL, using HTTP or HTTPS.
 *
 * @param url       The URL to open. Protocol must be HTTP or HTTPS.
 * @param buffer    The buffer to write the results to.
 * @param len       How many bytes to write to the buffer.
 * @return The real amount of bytes read, or -1 on error.
 */
int
curling_readURL(const char *url, char *buffer, int len);

#if __cplusplus
}
#endif

#endif //__CURLING_H

// vim: ft=cpp.doxygen
