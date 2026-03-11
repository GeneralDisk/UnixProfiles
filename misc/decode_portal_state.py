import sys

# portal state bits from psdrv_gpl/include/ps_bdrv/ps_bdrv.h
PS_STATE_NORESP                 = 0
PS_STATE_DEVIO_READY            = 1
PS_STATE_PORTAL_OPEN            = 2
PS_STATE_NOPARAMS               = 3

PS_STATE_NOBSIZES               = 4
PS_STATE_NOMEMINIT              = 5
PS_STATE_IOREQ_READ_READY       = 6
PS_STATE_IOREQ_WRITE_READY      = 7

PS_STATE_IOREQ_READ_DELAYED     = 8
PS_STATE_IOREQ_WRITE_DELAYED    = 9
PS_STATE_READ_TIMEDOUT          = 10
PS_STATE_WRITE_TIMEDOUT         = 11

PS_STATE_READ_ABSOLVED          = 12
PS_STATE_WRITE_ABSOLVED         = 13
PS_CSTATE_CLOSING               = 14
PS_CSTATE_ALLOC                 = 15

PS_CSTATE_TIMEOUT               = 16
PS_STATE_SYS_VOL_ALLOWED        = 17
PS_STATE_PRIMARY_VOL_ALLOWED    = 18
PS_STATE_SECONDARY_VOL_ALLOWED  = 19

PS_STATE_FORCED_TIMEOUT         = 20

def print_health_summary(key: str):
    """
    Expects a portal state input in the form of a HEX string
    Health report info from kernel/include/bdev/driver.h
    """
    def p_exit(health: str):
        print(f"Summary: {health}")
        return

    key_i = int(key, 16)
    # foed sick = PS_STATE_PORTAL_OPEN | PS_STATE_IOREQ_ALL_READY | PS_STATE_IOREQ_ALL_DELAYED
    # PS_STATE_IOREQ_ALL_DELAYED = PS_STATE_IOREQ_READ_DELAYED & PS_STATE_IOREQ_WRITE_DELAYED
    # sick absolved = (PS_STATE_IOREQ_READ_DELAYED | PS_STATE_IOREQ_WRITE_DELAYED) &
    #                           (PS_STATE_READ_ABSOLVED | PS_STATE_WRITE_ABSOLVED)
    # healthy absolved = (PS_STATE_READ_ABSOLVED | PS_STATE_WRITE_ABSOLVED)

    # if portal closed, nothing matters
    if not key_i & (1 << PS_STATE_PORTAL_OPEN):
        return p_exit("FOED Dead - Portal is closed!")

    # I/O ready?
    if not key_i & (1 << PS_STATE_IOREQ_READ_READY | 1 << PS_STATE_IOREQ_WRITE_READY):
        return p_exit("FOED Sick? I/O not read/write ready!")

    health_str = ""
    # check sick
    sick_type = ""
    foed_read_sick = key_i & (1 << PS_STATE_IOREQ_READ_DELAYED)
    foed_write_sick = key_i & (1 << PS_STATE_IOREQ_WRITE_DELAYED)
    foed_sick = foed_read_sick | foed_write_sick
    if foed_sick:
        if foed_read_sick and foed_write_sick:
            sick_type = "(read/write)"
        elif foed_read_sick:
            sick_type = "(read)"
        elif foed_write_sick:
            sick_type = "(write)"
        health_str = f"FOED Sick {sick_type}"
    else:
        health_str = "FOED Healthy"

    # Check absolution
    abslv_read = key_i & (1 << PS_STATE_READ_ABSOLVED)
    abslv_write = key_i & (1 << PS_STATE_WRITE_ABSOLVED)
    absolution_str = " - not absolved"
    if abslv_read and abslv_write:
        absolution_str = " - read/write absolved"
    elif abslv_read:
        absolution_str = " - read absolved"
    elif abslv_write:
        absolution_str = " - write absolved"

    health_str = health_str + absolution_str

    p_exit(health_str)

def print_portal_state(key: str):
    """
    Expects a portal state input in the form of a HEX string.
    """
    # Convert to int
    key_i = int(key, 16)
    # portal state decoding info in psdrv_gpl/include/ps_bdrv/ps_bdrv.h
    print(f"Decoding {key}")

    print(f"bit 0 (no response)             : {key_i >> PS_STATE_NORESP & 0x1}")
    print(f"bit 1 (devio ready)             : {key_i >> PS_STATE_DEVIO_READY & 0x1}")
    print(f"bit 2 (portal open)             : {key_i >> PS_STATE_PORTAL_OPEN & 0x1}")
    print(f"bit 3 (no params)               : {key_i >> PS_STATE_NOPARAMS & 0x1}")
    print("")

    print(f"bit 4 (no bsizes)               : {key_i >> PS_STATE_NOBSIZES & 0x1}")
    print(f"bit 5 (no mem init)             : {key_i >> PS_STATE_NOMEMINIT & 0x1}")
    print(f"bit 6 (read ready)              : {key_i >> PS_STATE_IOREQ_READ_READY & 0x1}")
    print(f"bit 7 (write ready)             : {key_i >> PS_STATE_IOREQ_WRITE_READY & 0x1}")
    print("")

    print(f"bit 8 (read delays)             : {key_i >> PS_STATE_IOREQ_READ_DELAYED & 0x1}")
    print(f"bit 9 (write delays)            : {key_i >> PS_STATE_IOREQ_WRITE_DELAYED & 0x1}")
    print(f"bit 10 (read timeouts)          : {key_i >> PS_STATE_READ_TIMEDOUT & 0x1}")
    print(f"bit 11 (write timeouts)         : {key_i >> PS_STATE_WRITE_TIMEDOUT & 0x1}")
    print("")

    print(f"bit 12 (read absolved)          : {key_i >> PS_STATE_READ_ABSOLVED & 0x1}")
    print(f"bit 13 (write absolved)         : {key_i >> PS_STATE_WRITE_ABSOLVED & 0x1}")
    print(f"bit 14 (cstate closing)         : {key_i >> PS_CSTATE_CLOSING & 0x1}")
    print(f"bit 15 (cstate alloc)           : {key_i >> PS_CSTATE_ALLOC & 0x1}")
    print("")

    print(f"bit 16 (cstate timeout)         : {key_i >> PS_CSTATE_TIMEOUT & 0x1}")
    print(f"bit 17 (system vol allowed)     : {key_i >> PS_STATE_SYS_VOL_ALLOWED & 0x1}")
    print(f"bit 18 (primary vol allowed)    : {key_i >> PS_STATE_PRIMARY_VOL_ALLOWED & 0x1}")
    print(f"bit 19 (secondary vol allowed)  : {key_i >> PS_STATE_SECONDARY_VOL_ALLOWED & 0x1}")
    print(f"bit 20 (forced timeout)         : {key_i >> PS_STATE_FORCED_TIMEOUT & 0x1}")
    print("")

def main():
    thing = "portal state"
    if len(sys.argv) <= 1:
        print("Please input a {thing} to decode")
        exit(1)
    keys = sys.argv[1:]
    verbose = False
    verbose = True
    print(f"Decoding {len(keys)} {thing}(s)")
    counter = 0
    for key in keys:
        counter += 1
        print(f" ----- {thing} {counter} ----- ")
        if verbose:
            print_portal_state(key)
        print_health_summary(key)
        print(" --------------- ")

    print(f"Successfully decoded {counter}/{len(keys)} {thing}(s)")

main()
