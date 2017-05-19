### Install R libraries ####
### this script uses environment variables to install R libraries
### Format:
### R_REPO_<REPO_NAME>=<REPO_URL>
### R_PKG_<REPO_NAME>=<PKG1>,<PKG2>,...<PKGN>
### Example:
### R_REPO_CRAN=http://cran.us.r-project.org
### R_PKG_CRAN=devtools,reshape2,digest

env <- Sys.getenv()

for(ndx in grep("^R_REPO_", names(env))) {
        # get the name of the repo from the ENV variable name
        repo_name<-strsplit(names(env[ndx]), "^R_REPO_")[[1:2]]
        # get the associated URL
        repo_url<-env[ndx]

        # get the packages based on the repo name
        packages<- env[paste("R_PKG_", repo_name, sep="")]
        print(packages)
        for(pkg in strsplit(packages, ",")[[1]]) {

            if (pkg != "" && !require(pkg,character.only = TRUE)) {
                print(paste("installing", pkg, "from", repo_url, sep=" "))
                withCallingHandlers(install.packages(pkg, repos=repo_url),
                    warning = function(w) {
                        print(paste("ERROR/WARNING: ", w))
                        stop(w)
                    }
                )
            }
        }
}
