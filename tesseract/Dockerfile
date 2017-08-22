FROM debian:jessie
MAINTAINER Andre Rosa <andre_rosa@hms.harvard.edu>

ENV TESSDATA_PREFIX /usr/local/share/tessdata

# TODO: Add build args for leptonica and tesseract versioning

RUN set -xe \
    && export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib \
    && apt-get update \
    && apt-get install -y g++ \
                          wget \
                          autogen \
                          autoconf \
                          automake \
                          autoconf-archive \
                          pkg-config \
                          git \
                          libpng12-dev \
                          libjpeg62-turbo-dev \
                          libtiff5-dev \
                          zlib1g-dev \
                          libcairo2 \
                          libcairo2-dev \
                          libgomp1 \
                          libicu52 \
                          libicu-dev \
                          libpango1.0-0 \
                          libpango1.0-dev \
                          libtool \
    # install leptonica
    && git clone --branch 1.74.4 https://github.com/DanBloomberg/leptonica.git \
        && cd leptonica \
        && ./autobuild \
        && ./configure \
        && make \
        && make install \
        && cd .. \

    # install tesseract
    && git clone --branch 4.00.00alpha https://github.com/tesseract-ocr/tesseract.git \
        && cd tesseract \
        && ./autogen.sh \
        && ./configure \
        && LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make \
        && make install \
        # configure tesseract
        && ldconfig \
        && make training \
        && make training-install \
        && cd .. \

    # install tess data
    # english
    && wget -O ${TESSDATA_PREFIX}/eng.traineddata \
        https://github.com/tesseract-ocr/tessdata/raw/4.00/eng.traineddata \
    # orientation and script detection
    && wget -O ${TESSDATA_PREFIX}/osd.traineddata \
        https://github.com/tesseract-ocr/tessdata/raw/4.00/osd.traineddata \
    # math / equation detection
    && wget -O ${TESSDATA_PREFIX}/equ.traineddata \
        https://github.com/tesseract-ocr/tessdata/raw/4.00/equ.traineddata \
    # french (why not.)
    && wget -O ${TESSDATA_PREFIX}/fra.traineddata \
        https://github.com/tesseract-ocr/tessdata/raw/4.00/fra.traineddata \


    # move training scripts to /usr/bin/
    && mv tesseract/training/*.sh /usr/bin/ \

    # clean up
    && apt-get purge --auto-remove -y g++ \
                          wget \
                          autogen \
                          autoconf \
                          automake \
                          autoconf-archive \
                          pkg-config \
                          libpng12-dev \
                          git \
                          libcairo2-dev \
                          libicu-dev \
                          libpango1.0-dev \
                          libtool \

    # test and verify tesseract
    && tesseract --version \
        && cd tesseract/testing \
        && tesseract eurotext.tif out -l eng \
        && cat out.txt \
    && rm -rf tesseract leptonica /var/cache/apk/* rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["tesseract"]
CMD ["-h"]
