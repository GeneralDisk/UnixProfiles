import sys
import pprint

"""
This janky script takes in a std input and parses the output to fit in a grep string.

Modify idx for the correct word, and you'll probably have to mess with "parse" to get whatever
it is you actually want out of the string see text.log for what this was developed to parse

cat text.log | python3 pull_log_and_format.py
"""

def parse(word, delimit_left, delimit_right):
    if not delimit_left is None:
        word = word.split(delimit_left)[-1]
    if not delimit_right is None:
        word = word.split(delimit_right)[0]
    return word



def wordify_line(line, debug):
    # Takes a string, and pulls out a list of words, no spaces
    words = []
    word = ""
    for ch in line:
        if ch == " " or ch == "\n":
            if debug:
                print(f" - Word: {word}")
            words.append(word)
            word = ""
        else:
            word = f"{word}{ch}"

    return words

def remove_duplicates_of(character, line):
    # remove duplicates of 'character' after first from a line
    prev_ch = None
    new_line = ""
    for ch in line:
        if ch == character and ch == prev_ch:
            continue
        else:
            new_line = f"{new_line}{ch}"

        prev_ch = ch
    return new_line

def get_word(line, word_idx, del_l = None, del_r = None):
    """
    Get a word from a line at a specified index, with optional delimiters (left and right)
    """
    output = ""
    try:
        output = parse(wordify_line(line, False)[word_idx], del_l, del_r)
    except:
        print("Encoutnered error parsing word generated from the following:")
        print(f"    Output: {output}")
        print(f"    line: {line}")
        print(f"    wordify: {wordify_line(line, False)}")
        print(f"    idx: {word_idx}")
        print(f"    --> parse(wordify_line(line)[word_idx], del_l, del_r)")
        print(f"Debug:")
        print(f" -- wordify --")
        wordify_line(line, True)
        print(f"Debug END")
        raise Exception("Encountered Parsing Error while getting word")
    return output

def main():

    if len(sys.argv) <= 1:
        print("Please input an column idx to target")
        exit(1)
    print(f"Index: {sys.argv[0]} {sys.argv[1]}")
    idx = int(sys.argv[1])

    lines_raw = sys.stdin.readlines()


    lines = []
    for ln in lines_raw:
        nln = remove_duplicates_of(" ", ln)
        lines.append(nln)
    # Format output string
    output = ""
    for ln in lines:
        #lines_w.append(wordify_line(ln))
        try:
            word = get_word(ln, idx)
            output = f"{output}\|{word}"
        except:
            exit(1)

    print(output)
    # Format output string
    """
    output = ""
    for ln in lines:
        #lines_w.append(wordify_line(ln))
        try:
            output = f"{output}\|{parse(wordify_line(ln, False)[idx])}"
        except:
            print("Encoutnered error parsing word generated from the following:")
            print(f"    Output: {output}")
            print(f"    ln: {ln}")
            print(f"    wordify: {wordify_line(ln, False)}")
            print(f"    idx: {idx}")
            print(f"    --> parse(wordify_line(ln)[idx])")
            print(f"Debug:")
            print(f" -- wordify --")
            wordify_line(ln, True)
            print(f"Debug END")

            exit(1)

    print(output)
    #print(lines_w[0])
    """
    #parse(lines_w[0][idx])

main()
