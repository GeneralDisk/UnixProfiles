import subprocess as sp
import pprint

print("Grabbing find_drive.py info")

find_drv = sp.check_output("find_drive.py")

print("parsing")

spl = find_drv.split("\n")

class simple_drive:
    name = ""
    model = ""
    node = ""
    location = ""

    def __init__(self, name, model, node, location):
        self.name = name
        self.model = model
        self.node = node
        self.location = location

    def info(self):
        return "{} - {} - {} located at {}".format(self.node, self.name, self.model, self.location)


filtered=[]

arg_filter="90024-9"
for ln in spl:
    if "dev" in ln and "nvme" in ln:
        if arg_filter is None or arg_filter in ln:
            print(ln)
            splt = ln.split()
            filtered.append(simple_drive(splt[6], splt[4], splt[0], splt[9]))

num = len(filtered)
print("Running reservation report on {} nodes".format(len(filtered)))
for drv in filtered:
    print("\n - Resrv Report for {}".format(drv.info()))
    rpt = sp.check_output(['nvme', 'reservation', 'report', drv.node])
    print(rpt)

print("Done")
