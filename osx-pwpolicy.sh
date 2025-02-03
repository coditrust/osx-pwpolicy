#!/bin/sh

###################################################################################
##   Create a pwpolicy XML file based upon variables and options included below.
##   Policy is applied and then file gets deleted.
##   Use "sudo pwpolicy -u <user> -getaccountpolicies"
##   to see it, and "sudo pwpolicy -u <user> -clearaccountpolicies" to clear it.
##
##    Tested on: OS X  10.10  10.11  10.12 10.13? 10.14 10.15
####################################################################################

#########################################
# Make sure only root can run our script
#
if [ "$(id -u)" != "0" ]; then
        echo "Please run this script as root" 1>&2
        exit 1
fi
##########################################

#############################################################################
# Variables for script and commands generated below.
# EDIT AS NECESSARY FOR YOUR OWN PASSWORD POLICY
#
#MAX_FAILED=10                   # 10 max failed logins before locking

PW_EXPIRE=360                   # 180 days password expiration
MIN_LENGTH=12                   # at least 10 chars for password
MIN_ALPHA_LOWER=1               # at least 1 lower case letter in password
MIN_UPPER_ALPHA=1               # at least 1 upper case letter in password
MIN_SPECIAL_CHAR=1              # at least one special character in password
PW_HISTORY=3                    # remember last 3 passwords
#
##############################################################################

###################################################
# create pwpolicy.plist in /private/var/tmp
# Password policy using variables above is:
# Change as necessary in variable flowerbox above
# -------------------------------------------------

echo "
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>policyCategoryPasswordChange</key>
<array>
<dict>
<key>policyContent</key>
<string>policyAttributeCurrentTime &gt; policyAttributeLastPasswordChangeTime + (policyAttributeExpiresEveryNDays * 24 * 60 * 60)</string>
<key>policyIdentifier</key>
<string>Change every ${PW_EXPIRE} days</string>
<key>policyParameters</key>
<dict>
<key>policyAttributeExpiresEveryNDays</key>
<integer>${PW_EXPIRE}</integer>
</dict>
</dict>
</array>
<key>policyCategoryPasswordContent</key>
<array>
<dict>
<key>policyContent</key>
<string>policyAttributePassword matches '.{${MIN_LENGTH},}+'</string>
<key>policyIdentifier</key>
<string>Has at least ${MIN_LENGTH} characters</string>
<key>policyParameters</key>
<dict>
<key>minimumLength</key>
<integer>${MIN_LENGTH}</integer>
</dict>
</dict>
<dict>
<key>policyContent</key>
<string>policyAttributePassword matches '(.*[a-z].*){${MIN_ALPHA_LOWER},}+'</string>
<key>policyIdentifier</key>
<string>Has a lower case letter</string>
<key>policyParameters</key>
<dict>
<key>minimumAlphaCharactersLowerCase</key>
<integer>${MIN_ALPHA_LOWER}</integer>
</dict>
</dict>
<dict>
<key>policyContent</key>
<string>policyAttributePassword matches '(.*[A-Z].*){${MIN_UPPER_ALPHA},}+'</string>
<key>policyIdentifier</key>
<string>Has an upper case letter</string>
<key>policyParameters</key>
<dict>
<key>minimumAlphaCharacters</key>
<integer>${MIN_UPPER_ALPHA}</integer>
</dict>
</dict>
<dict>
<key>policyContent</key>
<string>policyAttributePassword matches '(.*[^a-zA-Z0-9].*){${MIN_SPECIAL_CHAR},}+'</string>
<key>policyIdentifier</key>
<string>Has a special character</string>
<key>policyParameters</key>
<dict>
<key>minimumSymbols</key>
<integer>${MIN_SPECIAL_CHAR}</integer>
</dict>
</dict>
<dict>
<key>policyContent</key>
<string>none policyAttributePasswordHashes in policyAttributePasswordHistory</string>
<key>policyIdentifier</key>
<string>Does not match any of last ${PW_HISTORY} passwords</string>
<key>policyParameters</key>
<dict>
<key>policyAttributePasswordHistoryDepth</key>
<integer>${PW_HISTORY}</integer>
</dict>
</dict>
</array>
</dict>
</plist>" > /private/var/tmp/pwpolicy.plist

##### end of pwpolicy.plist generation script
###################################################

# clear account policy before loading a new one
pwpolicy -clearaccountpolicies
pwpolicy -setaccountpolicies /private/var/tmp/pwpolicy.plist

#delete staged pwpolicy.plist
rm -f /private/var/tmp/pwpolicy.plist

echo "Password policy successfully applied. Run \"sudo pwpolicy -getaccountpolicies\" to see it."
exit 0
