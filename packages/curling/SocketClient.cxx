/**
 * @file        SocketClient.cxx
 * @author      Karim Vergnes <me@thesola.io>
 * @copyright   GPLv2
 * @brief       TLS wrapper around wxSocketClient
 *
 * First step in interposing TLS into wxHTTP.
 */

#include "curling.h"

int
validate_certificate (struct TLSContext *ctx, struct TLSCertificate **chain, int len)
{
    return no_error; // huehuehue
}


CurlingTLSSocketClient::CurlingTLSSocketClient(wxSocketFlags flags)
    : wxSocketClient(flags)
{
    ctx = tls_create_context(0, TLS_V12);
}

CurlingTLSSocketClient::~CurlingTLSSocketClient()
{
    tls_destroy_context(ctx);
}

bool
CurlingTLSSocketClient::Connect(wxIPaddress& addr, bool wait)
{
    wxSocketClient::Connect(addr, wait);

    /*if (!tls_sni_set(ctx, addr.Hostname().c_str())) {
        printf("CurlingTLSSocketClient: setting hostname to %s failed!\n", addr.Hostname().c_str());
        return false;
    }*/

    tls_client_connect(ctx);
    Flush();
    return true;
}

wxSocketBase &
CurlingTLSSocketClient::Read(void *buffer, wxUint32 length)
{
    printf("CurlingTLSSocketClient: reading %d bytes", length);

    unsigned char rawbuf[length];

    wxSocketBase::Read(rawbuf, length);

    tls_consume_stream(ctx, rawbuf, length, validate_certificate);

    tls_read(ctx, (unsigned char *)buffer, (unsigned int)length);

    return *this;
}

wxSocketBase &
CurlingTLSSocketClient::Write(const void *buffer, wxUint32 length)
{
    printf("CurlingTLSSocketClient: writing %d bytes", length);

    tls_write(ctx, (const unsigned char *)buffer, length);

    return Flush();
}

wxSocketBase &
CurlingTLSSocketClient::Flush()
{
    unsigned int out_len = 0;
    const unsigned char *out_buffer = tls_get_write_buffer(ctx, &out_len);

    wxSocketBase::Write(out_buffer, out_len);

    tls_buffer_clear(ctx);
    return *this;
}

bool
CurlingTLSSocketClient::Close()
{
    tls_close_notify(ctx);

    Flush();

    return wxSocketBase::Close();
}

// vim: ft=cpp.doxygen
