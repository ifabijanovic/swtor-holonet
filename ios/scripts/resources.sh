#!/bin/sh

if [ -f "${PROJECT_DIR}/SWTOR HoloNet/GoogleService-Info.plist" ]; then 
  cp "${PROJECT_DIR}/SWTOR HoloNet/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
fi

