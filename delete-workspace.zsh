#!/bin/bash
 
read_props_as_env()
{
   echo "Reading ${1} as environment variables"
   while read line; do
      line=$(echo $line | tr -d '\r')
      export $line
   done < $1
}

read_props_as_env env.properties

# Get user input
echo ""
echo -n "Workspace name: "
read workspace_name

git_user=`git config github.user`
if [[ -z ${git_user} ]]; then
   echo -n "Github username: "
   read git_user
   git config github.user ${git_user}
fi

# Invoke Github admin api 
curl -X DELETE -H "Accept: application/vnd.github.v3+json" -u ${git_user}:${github_automation_key} https://api.github.com/repos/${git_user}/${workspace_name}
echo ""
echo "Remote repo ${workspace_name} deleted"

cd ${parent_dir}
rm -rf ${workspace_name}
echo "Local workspace ${parent_dir}/${workspace_name} deleted"
