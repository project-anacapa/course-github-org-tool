# Issue: Organization not showing up

Problem: When attempting to set up a course in the course-github-org-tool interface, the desired organization does not show up.

## Resolution 1: Remove Access Restrictions from your Organization

The reason it might not be showing up is that your organization is currently restricted and you have not yet authorized the application. 

In order to remove the restriction, you can visit the restriction settings page at `https://github.com/organizations/<<your-org>>/settings/oauth_application_policy`, where `<<your-org>>` is the name of the GitHub Organization you would like to use for your course, such as `UCSB-CS123-W17` or `Narnia-CS345-F13`.

Simply click the 'Remove Third Party Access Restrictions' button and try setting up your course again. It should show up.

## Resolution 2: Retry Authorization

In order to view the OAuth authorization query page from when you first signed in again, you must revoke access from your OAuth application from your account. 

In order to do this, visit your [authorized applications](https://github.com/settings/applications) page and click "Revoke" for the application that your version of the `course-github-org-tool` is using.

Next, sign out of the `course-github-org-tool` and re-sign-in. When presented with the GitHub OAuth page, click the "Grant access" button next to the organization you wish to use. 
