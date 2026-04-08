# Review Package: ReleaseBundle Approve
- transition: ReleaseBundle.candidate -> ReleaseBundle.approved
- includes deployment.failed and rollback path
