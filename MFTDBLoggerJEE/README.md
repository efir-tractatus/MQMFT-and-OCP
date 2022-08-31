### Running an MFT DB Logger JEE in OpenShift

How to have a separate pod in OCP running Liberty to do the MFT DB Logging.

---

This should be installed in the same namesapce/project as the MQ MFT QMGRs.

The `buildMFTDBLogger.yaml` script will:

1. Create an `ImageStream` for the image to be stored after building
2. Create a `BuildConfig` to use the `Dockerfile` from this directory to build the image
3. Install IBM Container Register (ICR) `CatalogSource`
4. Install the Liberty Operator from the ICR
5. Create a `Secret` with all the necessary variables to communicate with MFT Coordination QMGR and Database
6. Create a Liberty Application using the Liberty Operator and ImageStream from Build

The `Secret` needs to be changed to match the target environment. The Liberty Appolication will need to pull from the correct namespace.  In addition, the keystore needs to be updated with any certificates that need to be trusted before building.

After submitting the script above, a build needs to be initiated:

```
oc start-build build-mft-db-logger -n <namespace>
```

---

For DB2 or other DBs, the application in the dropins folder needs to be replaced with the correct .ear file from the MQMFT directory and the server.xml would need to be updated from Oracle to DB2.  The Dockerfile would need to be updated to pull the latest DB2 JDBC driver.
