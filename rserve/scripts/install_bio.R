bio_url<-Sys.getenv("R_BIO_URL")
source(bio_url)
for(pkg in strsplit(Sys.getenv("R_BIO_PKG"), ",")[[1]]) {
    print(paste("installing", pkg, "from", bio_url, sep=" "))
    biocLite(pkg)
}
