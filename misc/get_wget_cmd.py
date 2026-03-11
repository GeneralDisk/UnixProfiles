import sys
import urllib.request

def is_pflow(url) -> bool:
    # ex = https://metroidjenkins.dev.purestorage.com/job/p_flow/7080/
    spl = url.split("/")
    if len(spl) != 7 or spl[-1] != '' or (spl[0] != 'https:' and spl[0] != 'http:'):
        # make sure no garbage is passed and we have a good URL
        return False
    validation_str = "p_flow"
    # last entry is '', second to last is the job #, third is p_flow
    val_idx = -3
    if spl[val_idx] != validation_str:
        return False

    strs_in_valid_url = [validation_str, "jenkins"]
    for str_v in strs_in_valid_url:
        if not str_v in url:
            return False

    return True

def is_setup_details(url) -> bool:
    spl = url.split("/")
    if len(spl) != 8 or (spl[0] != 'https:' and spl[0] != 'http:'):
        # make sure no garbage is passed and we have a good URL
        return False
    validation_str = "setup_details.txt"
    # last entry is '', second to last is the job #, third is p_flow
    val_idx = -1
    if spl[val_idx] != validation_str:
        return False

    strs_in_valid_url = [validation_str, "jenkins"]
    # is "setup_details.txt" present, and "jenkins"
    for str_v in strs_in_valid_url:
        if not str_v in url:
            return False
    return True

def pflow_to_setupdetails(url) -> str:
    # setup_details is always in the artifact directory for the job
    return url + "artifact/setup_details.txt"

def get_files_from_setup_details_url(url) -> list:
    print(f"Grabbing info from '{url}'...")
    f = urllib.request.urlopen(url)
    raw_txt = f.read().decode('utf-8')
    raw_lns = raw_txt.splitlines()
    keys_to_grab = ["ppkg_url", "ppkg_sha1_url"]
    files_to_get = []
    for ln in raw_lns:
        key, value = ln.split("=")
        if key in keys_to_grab:
            files_to_get.append(value)
    return files_to_get

def main():
    arg_l = len(sys.argv)
    if arg_l <= 1 or arg_l > 2:
        print("Pass one and only one valid URL to the setup_details.txt file please")
        exit(1)

    url = sys.argv[1]
    # Two valid URLs, p_flow, and setup_details.txt
    if is_pflow(url):
        url = pflow_to_setupdetails(url)

    if not is_setup_details(url):
        print(f"ERROR: URL invalid - can only parse a p_flow or setup_details.txt url")
        exit(1)

    file_urls = get_files_from_setup_details_url(url)
    # print the final wget cmd
    cmd = ""
    for file in file_urls:
        cmd += f"wget {file}; "

    print("Command to use:")
    print(cmd)

main()
