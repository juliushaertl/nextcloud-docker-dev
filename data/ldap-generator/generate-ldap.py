import json
import random

domain = "planetexpress.com"
base = "dc=planetexpress,dc=com"
ou_users= "ou=people,%s" % base
ou_groups = "ou=groups,%s" % base

template_group = '''
dn: cn={cn},{ou_groups}
objectclass: groupOfNames
objectclass: top
cn: {cn}
description: {displayName}
'''

template_user = '''
dn: cn={cn},{ou_users}
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
cn: {cn}
sn: {cn}
description: {description}
givenName: {givenName}
mail: {uid}@{domain}
uid: {uid}
userPassword: {password}
'''

# Generate named groups from json with n random users per group
users_per_group = 20
# Generate groups "Group %d"
random_groups = 50
users_per_random_group = 50

users = ""
groups = ""

def generate_user(i = None):
    fn = first_names[random.randint(0, len(first_names)-1)]
    ln = last_names[random.randint(0, len(last_names)-1)]
    cn = "%s %s" % (fn, ln)
    uid = "%s%s" % (fn, ln)

    if i:
        fn = "Robot%s" % i
        ln = "Unit%s" % i
        cn = "robotunit%s" %i
        uid = "robotunit%s" %i

    user_ldif = (template_user.format(cn=cn, uid=uid, password=uid, description="a user", givenName=fn, ou_users=ou_users, domain=domain))
    return (fn, ln, cn, uid, user_ldif)

uid_list = []
with open('names.json') as json_file:
    data = json.load(json_file)
    first_names = data['fns']
    last_names = data['sns']

    for group in data['groups']:
        groups += template_group.format(cn=group, displayName=group, ou_groups=ou_groups, domain=domain)
        for i in range(0, users_per_group):
            user = generate_user()
            users += user[4] + "\n"
            groups += "member: cn={cn},{ou_users}\n".format(cn=user[2], ou_users=ou_users)

    for gid in range(0, random_groups):
        randomGroup = ("Robots %d" % gid)
        groups += template_group.format(cn=randomGroup, displayName=randomGroup, ou_groups=ou_groups, domain=domain)
        for i in range(0, users_per_random_group):
            user = generate_user("%d-%d" % (gid, i))
            users += user[4] + "\n"
            groups += "member: cn={cn},{ou_users}\n".format(cn=user[2], ou_users=ou_users)



print(users)
print(groups)



