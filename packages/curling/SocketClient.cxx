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
validate_certificate (struct TLSContext *ctx, struct TLSCertificate *chain, int len)
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

    if (!tls_sni_set(ctx, addr.Hostname())) {
        return false;
    }

    tls_client_connect(ctx);
    Flush();
}

CurlingTLSSocketClient &
CurlingTLSSocketClient::Read(void *buffer, wxUint32 length)
{
    unsigned char rawbuf[length];

    wxSocketClient::Read(rawbuf, length);

    tls_consume_stream(ctx, rawbuf, length, (tls_validation_function) validate_certificate);

    tls_read(ctx, (unsigned char *)buffer, (unsigned int)length);
}

CurlingTLSSocketClient &
CurlingTLSSocketClient::Write(const void *buffer, wxUint32 length)
{
    tls_write(ctx, (const unsigned char *)buffer, length);

    Flush();
}

CurlingTLSSocketClient &
CurlingTLSSocketClient::Flush()
{
    unsigned int out_len = 0;
    const unsigned char *out_buffer = tls_get_write_buffer(ctx, &out_len);

    wxSocketClient::Write(out_buffer, out_len);

    tls_buffer_clear(ctx);
}

bool
CurlingTLSSocketClient::Close()
{
    tls_close_notify(ctx);

    Flush();

    return wxSocketClient::Close();
}

// vim: ft=cpp.doxygen
