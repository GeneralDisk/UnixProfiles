import sys

def decode_eager(eager: int):
    # eager primary, or reluctant / inviting takeover.
    # eager == 0, reluctant == 1
    if eager:
        return "Reluctant - takeover invited"
    else:
        return "Eager"

def decode_npiv(npiv: int):
    if npiv == 0:
        # Bit 35 indicates if NPIV is valid/invalid. 0 == valid, 1 == invalid
        # so a total int value of 0 means, valid/inactive
        # Transparent failover inactive
        return "valid/inactive"
    elif npiv == 2:
        # bits 10 is the only other valid state we need to worry about
        # Transparent failover active
        return "valid/active"
    else:
        # Transparent failover ignore
        return "NPIV Disabled"

def decode_prefix(prefix: int):
    if prefix == 1:
        return "Claim"
    elif prefix == 2:
        return "Heartbeat"
    elif prefix == 3:
        return "SSD Reset"
    elif prefix == 4:
        return "External (e.g. puredrive erase)"
    elif prefix == 255:
        return "Boot/Reset"
    else:
        return "Unknown"

def get_rem_san_mask(key: str):
    # Convert to int
    key_i = int(key, 16)
    return (key_i >> 8) & 0x1

def get_conf_seq(key: str):
    key_i = int(key, 16)
    return (key_i >> 9) & 0xffff

def get_epoch(key: str):
    key_i = int(key, 16)
    return (key_i >> 25) & 0xff


def get_eager(key: str):
    key_i = int(key, 16)
    return (key_i >> 33) & 0x1

def get_npiv(key: str):
    key_i = int(key, 16)
    return (key_i >> 35) & 0x3

def get_prefix(key: str):
    key_i = int(key, 16)
    return (key_i >> 56) & 0xff

def get_all(key: str):
    return {"rsan_mask": get_rem_san_mask(key),
                "conf_seq": get_conf_seq(key),
                "epoch": get_epoch(key),
                "eager": get_eager(key),
                "npiv": get_npiv(key),
                "prefix": get_prefix(key)}

def print_key(key: str):
    """
    Expects a reservation key input in the form of a HEX string.
    """
    # Convert to int
    key_i = int(key, 16)
    # Thanks Shagun for the print format that I copied here
    # Key decoding info in platform/include/storage/storage.h
    print(f"Decoding {key}")
    print(f"bit 0-7 (unused)                    : {key_i & 0xff}")
    print(f"bit 8 (remote_san_mask)             : {get_rem_san_mask(key)}")
    print(f"bit 9-24 (config seq number)        : {get_conf_seq(key)}")
    print(f"bit 25-32 (epoch)                   : {get_epoch(key)}")
    eager = get_eager(key)
    print(f"bit 33 (eagar/reluctant)            : {eager} - {decode_eager(eager)}")
    npiv = get_npiv(key)
    print(f"bit 35-36 (NPIV active/inactive)    : {npiv} - {decode_npiv(npiv)}")
    print(f"bit 37-55 (reserved)")
    prefix = get_prefix(key)
    print(f"bit 56-63 (Key Type)                : {prefix} - {decode_prefix(prefix)}")
    print("")
    """
    print(f"Decoding {key}")
    print(f"bit 0-7 (unused)                    : {key_i & 0xff}")
    print(f"bit 8 (remote_san_mask)             : {(key_i >> 8) & 0x1}")
    print(f"bit 9-24 (config seq number)        : {(key_i >> 9) & 0xffff}")
    print(f"bit 25-32 (epoch)                   : {(key_i >> 25) & 0xff}")
    eager = (key_i >> 33) & 0x1
    print(f"bit 33 (eagar/reluctant)            : {eager} - {decode_eager(eager)}")
    npiv = (key_i >> 35) & 0x3
    print(f"bit 35-36 (NPIV active/inactive)    : {npiv} - {decode_npiv(npiv)}")
    print(f"bit 37-55 (reserved)")
    prefix = (key_i >> 56) & 0xff
    print(f"bit 56-63 (Key Type)                : {prefix} - {decode_prefix(prefix)}")
    print("")
    """
