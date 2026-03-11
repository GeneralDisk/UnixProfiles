import sys
import reservation_keys as rk

def main():
    if len(sys.argv) <= 1:
        print("Please input a reservation key to decode")
        exit(1)

    keys = sys.argv[1:]
    print(f"Decoding {len(keys)} key(s)")
    counter = 0
    for key in keys:
        counter += 1
        print(f" - Key {counter} - ")
        rk.print_key(key)

    print(f"Successfully decoded {counter}/{len(keys)} key(s)")

main()
