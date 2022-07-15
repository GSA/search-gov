## Summary
- Brief summary of the changes included in this PR
- Any additional information or context which may help the reviewer
 
### Checklist
Please ensure you have addressed all concerns below before marking a PR "ready for review" or before requesting a re-review. If you cannot complete an item below, replace the checkbox with the ⚠️ `:warning:` emoji and explain why the step was not completed.
 
#### Functionality Checks

- [ ] You have run `bundle update` and committed your changes to Gemfile.lock.
 
- [ ] You have merged the latest changes from the target branch (usually `main`) into your branch.
 
- [ ] You have squashed your commits into a single commit (exceptions: your PR includes commits with formatting-only changes, such as required by Rubocop or Cookstyle, or if this is a feature branch that includes multiple commits).
 
- [ ] Your primary commit message is of the format **SRCH-#### \<description\>** matching the associated Jira ticket.

- [ ] PR title is either of the format **SRCH-#### \<description\>** matching the associated Jira ticket (i.e. "SRCH-123 implement feature X"), or **Release - SRCH-####, SRCH-####, SRCH-####** matching the Jira ticket numbers in the release.
 
- [ ] Automated checks pass. If Code Climate checks do not pass, explain reason for failures:
 
#### Process Checks

- [ ] You have specified at least one "Reviewer".