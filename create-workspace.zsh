#!/bin/bash
 
# Forked from https://gist.githubusercontent.com/jerrykrinock/6618003/raw/0f431bcf161cd5d30ccc8f6f9410acc36f94eb20/gitcreate.sh 

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
echo -n "Workspace description: "
read workspace_descrition
echo -n "Private repository [y or n]: "
read is_private_workspace

if [[ ${is_private_workspace} == "Y" ]] || [[ ${is_private_workspace} == "y" ]]; then
   export is_private_workspace="true"
else
   export is_private_workspace="false"
fi

git_user=`git config github.user`
if [[ -z ${git_user} ]]; then
   echo -n "Github username: "
   read git_user
   git config github.user ${git_user}
fi	

# Invoke Github admin api 
curl -X POST -H "Accept: application/vnd.github.v3+json" -u ${git_user}:${github_automation_key} https://api.github.com/user/repos -d "{\"name\": \"${workspace_name}\",\"description\": \"${workspace_descrition}\",\"private\": ${is_private_workspace},\"has_issues\": true,\"has_downloads\": true,\"has_wiki\": false}"
echo ""
echo "Remote repo created for ${workspace_name}"

# Crate local workspace
mkdir ${parent_dir}/${workspace_name}
cd ${parent_dir}/${workspace_name}
git init
git branch -M main
git remote add origin git@github.com:${git_user}/${workspace_name}.git
git push -u origin master
echo "Local workspace created at ${parent_dir}/${workspace_name}"

# Schedule for periodic sync
if [[ -f ${git_repo_log} ]]; then
   echo "git@github.com:${git_user}/${workspace_name}.git" >> ${git_repo_log}
   echo "Added https://github.com/${git_user}/${workspace_name}.git to ${git_repo_log}"
fi	

