/**
 * @file        SocketClient.cxx
 * @author      Karim Vergnes <me@thesola.io>
 * @copyright   GPLv2
 * @brief       TLS wrapper around wxSocketClient
 *
 * First step in interposing TLS into wxHTTP.
 */

#include "curling.h"

static unsigned char rawMessage[8192];

int
validate_certificate (struct TLSContext *ctx, struct TLSCertificate **chain, int len)
{
    return no_error; // huehuehue
}


CurlingTLSSocketClient::CurlingTLSSocketClient(wxSocketFlags flags)
    : wxSocketClient(flags)
{
    tls_init();

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

    int handshakeTTL = 40;

    /*if (!tls_sni_set(ctx, addr.Hostname().c_str())) {
        printf("CurlingTLSSocketClient: setting hostname to %s failed!\n", addr.Hostname().c_str());
        return false;
    }*/

    tls_client_connect(ctx);
    Flush();

    while (!tls_established(ctx)) {
        Discard();
        Flush();
        handshakeTTL -= 1;
        if (handshakeTTL == 0) {
            printf("TLS connection failed!\n");
            return false;
        }
    }
    return true;
}

wxSocketBase &
CurlingTLSSocketClient::Read(void *buffer, wxUint32 length)
{
    int res = 0;

    printf("CurlingTLSSocketClient: reading %d bytes", length);

    wxSocketBase::Read(rawMessage, sizeof(rawMessage));

    res = tls_consume_stream(ctx, rawMessage, sizeof(rawMessage), validate_certificate);

    if (res < 0) {
        printf("TLS read error!\n");
        return *this;
    }

    tls_read(ctx, (unsigned char *)buffer, (unsigned int)length);

    tls_buffer_clear(ctx);
    return *this;
}

wxSocketBase &
CurlingTLSSocketClient::Write(const void *buffer, wxUint32 length)
{
    printf("CurlingTLSSocketClient: writing %d bytes", length);

    tls_write(ctx, (const unsigned char *)buffer, length);

    return Flush();
}

wxSocketBase&
CurlingTLSSocketClient::Discard()
{
    int res = 0;

    wxSocketBase::Read(rawMessage, sizeof(rawMessage));
    res = tls_consume_stream(ctx, rawMessage, sizeof(rawMessage), validate_certificate);
    tls_buffer_clear(ctx);

    if (res < 0) {
        printf("TLS handshake error!\n");
        return *this;
    }

    return *this;
}

wxSocketBase &
CurlingTLSSocketClient::Flush()
{
    unsigned int out_len = 0;
    const unsigned char *out_buffer = tls_get_write_buffer(ctx, &out_len);

    while ((out_buffer) && (out_len > 0)) {
        wxSocketBase::Write(out_buffer, out_len);

        out_buffer = tls_get_write_buffer(ctx, &out_len);
    }

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
