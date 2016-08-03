#!/bin/sh
set -e

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

case "${TARGETED_DEVICE_FAMILY}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

realpath() {
  DIRECTORY="$(cd "${1%/*}" && pwd)"
  FILENAME="${1##*/}"
  echo "$DIRECTORY/$FILENAME"
}

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\""
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\""
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE=$(realpath "$RESOURCE_PATH")
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH"
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/avator@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/face@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/face_HL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/Fav_Cell_Loc@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/input-bar-flat.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/input-bar-flat@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/keyboard@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/keyboard_HL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/MessageVideoPlay@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/msg_chat_voice_unread.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/msg_chat_voice_unread@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/multiMedia@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/multiMedia_HL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/placeholderImage@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying000@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying001@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying002@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying003@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordCancel@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingBkg@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal001@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal002@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal003@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal004@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal005@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal006@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal007@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal008@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying000@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying001@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying002@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying003@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/voice@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/VoiceBtn_Black@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/VoiceBtn_BlackHL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/voice_HL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/weChatBubble_Receiving_Solid@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/weChatBubble_Sending_Solid@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/en.lproj"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SECoreTextView.bundle"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/zh-Hans.lproj"
  install_resource "XMPPFramework/Extensions/Roster/CoreDataStorage/XMPPRoster.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld/XMPPRoom.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld/XMPPRoomHybrid.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld/XMPPvCard.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0115/CoreDataStorage/XMPPCapabilities.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld/XMPPMessageArchiving.xcdatamodel"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/avator@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/face@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/face_HL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/Fav_Cell_Loc@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/input-bar-flat.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/input-bar-flat@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/keyboard@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/keyboard_HL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/MessageVideoPlay@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/msg_chat_voice_unread.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/msg_chat_voice_unread@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/multiMedia@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/multiMedia_HL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/placeholderImage@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying000@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying001@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying002@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying003@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/ReceiverVoiceNodePlaying@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordCancel@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingBkg@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal001@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal002@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal003@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal004@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal005@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal006@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal007@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/RecordingSignal008@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying000@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying001@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying002@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying003@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SenderVoiceNodePlaying@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/voice@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/VoiceBtn_Black@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/VoiceBtn_BlackHL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/voice_HL@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/weChatBubble_Receiving_Solid@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/weChatBubble_Sending_Solid@2x.png"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/en.lproj"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/SECoreTextView.bundle"
  install_resource "MessageDisplayKit/MessageDisplayKit/Resources/zh-Hans.lproj"
  install_resource "XMPPFramework/Extensions/Roster/CoreDataStorage/XMPPRoster.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0045/CoreDataStorage/XMPPRoom.xcdatamodeld/XMPPRoom.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0045/HybridStorage/XMPPRoomHybrid.xcdatamodeld/XMPPRoomHybrid.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0054/CoreDataStorage/XMPPvCard.xcdatamodeld/XMPPvCard.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0115/CoreDataStorage/XMPPCapabilities.xcdatamodel"
  install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld"
  install_resource "XMPPFramework/Extensions/XEP-0136/CoreDataStorage/XMPPMessageArchiving.xcdatamodeld/XMPPMessageArchiving.xcdatamodel"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "$XCASSET_FILES" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "`realpath $PODS_ROOT`*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
