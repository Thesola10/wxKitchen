/**
 * @file        HTTPS.cxx
 * @author      Karim Vergnes <me@thesola.io>
 * @copyright   GPLv2
 * @brief       TLS wrapper around wxHTTP
 *
 * Overrides wxHTTP to use our own SocketClient.
 *
 * A lot of the code is taken from wxHTTP and re-wired to use the TLS socket.
 */

#include "curling.h"

#include <wx/sckstrm.h>

class CurlingHTTPSStream : public wxSocketInputStream
{
public:
    CurlingHTTPS *m_http;
    size_t m_httpsize;
    unsigned long m_read_bytes;

    CurlingHTTPSStream(CurlingHTTPS *http)
        : wxSocketInputStream(*http->tlssock), m_http(http)
        {}
    size_t GetSize() const { return m_httpsize; }
    virtual ~CurlingHTTPSStream(void) { m_http->Abort(); }

protected:
    size_t OnSysRead(void *buffer, size_t bufsize);
};

size_t
CurlingHTTPSStream::OnSysRead(void *buffer, size_t bufsize)
{
    if (m_httpsize > 0 && m_read_bytes >= m_httpsize) {
        m_lasterror = wxSTREAM_EOF;
        return 0;
    }

    size_t ret = wxSocketInputStream::OnSysRead(buffer, bufsize);
    m_read_bytes += ret;

    if (m_httpsize == (size_t) -1 && m_lasterror == wxSTREAM_READ_ERROR)
        m_lasterror = wxSTREAM_EOF;

    return ret;
}


CurlingHTTPS::CurlingHTTPS() : wxHTTP()
{
    tlssock = new CurlingTLSSocketClient();
    m_addr = NULL;
    m_post_buf = wxEmptyString;
}

CurlingHTTPS::~CurlingHTTPS()
{
    delete tlssock;
}

bool
CurlingHTTPS::Connect(const wxString& host, unsigned short port)
{
    wxIPaddress *addr;

    if (m_addr) {
        delete m_addr;
        m_addr = NULL;
        Close();
    }

    m_addr = addr = new wxIPV4address();

    if (!addr->Hostname(host)) {
        delete m_addr;
        m_addr = NULL;
        m_perr = wxPROTO_NETERR;
        return false;
    }

    if (port)
        addr->Service(port);
    else if (!addr->Service(wxT("https")))
        addr->Service(443);

    SetHeader(wxT("Host"), host);

    return true;
}

bool
CurlingHTTPS::Connect(wxIPaddress& addr, bool wait)
{
    if (m_addr) {
        delete m_addr;
        Close();
    }

    m_addr = (wxIPaddress *) addr.Clone();

    wxIPV4address *ipv4addr = wxDynamicCast(&addr, wxIPV4address);
    if (ipv4addr)
        SetHeader(wxT("Host"), ipv4addr->OrigHostname());

    return true;
}

wxInputStream *
CurlingHTTPS::GetInputStream(const wxString& path)
{
    CurlingHTTPSStream *inp_stream;

    m_perr = wxPROTO_CONNERR;
    if (!m_addr) {
        printf("CurlingHTTPS: No address!\n");
        return NULL;
    }

    tlssock->Connect(*m_addr, true);

    if (!tlssock->IsConnected())
        return NULL;

    if (!BuildRequest(path, m_post_buf.empty() ? wxHTTP_GET : wxHTTP_POST)) {
        printf("CurlingHTTPS: Building request failed!\n");
        return NULL;
    }

    inp_stream = new CurlingHTTPSStream(this);

    if (!GetHeader(wxT("Content-Length")).empty())
        inp_stream->m_httpsize = wxAtoi(WXSTRINGCAST GetHeader(wxT("Content-Length")));
    else
        inp_stream->m_httpsize = (size_t) -1;

    inp_stream->m_read_bytes = 0;

    Notify(false);
    SetFlags(wxSOCKET_BLOCK | wxSOCKET_WAITALL);

    return inp_stream;
}

wxProtocolError
CurlingHTTPS::ReadLine(wxString &result)
{
    return wxProtocol::ReadLine(tlssock, result);
}

CurlingTLSSocketClient&
CurlingHTTPS::Write(const void *buffer, wxUint32 len)
{
    return tlssock->Write(buffer, len);
}

bool
CurlingHTTPS::Abort()
{
    return tlssock->Close();
}

bool
CurlingHTTPS::Close()
{
    return tlssock->Close();
}
