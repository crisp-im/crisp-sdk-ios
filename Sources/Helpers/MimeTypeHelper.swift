//
//  MimeTypeHelper.swift
//  Crisp
//
//  Created by Quentin de Quelen on 31/01/2017.
//  Copyright © 2017 qdequele. All rights reserved.
//

import Foundation

internal let DEFAULT_MIME_TYPE = "application/octet-stream"

enum mimeType: String {
    case html = "text/html"
    case css = "text/css"
    case xml = "text/xml"
    case gif = "image/gif"
    case jpeg = "image/jpeg"
    case js = "application/javascript"
    case atom = "application/atom+xml"
    case rss = "application/rss+xml"
    case mml = "text/mathml"
    case txt = "text/plain"
    case jad = "text/vnd.sun.j2me.app-descriptor"
    case wml = "text/vnd.wap.wml"
    case htc = "text/x-component"
    case md = "text/markdown"
    case png = "image/png"
    case tiff = "image/tiff"
    case wbmp = "image/vnd.wap.wbmp"
    case ico = "image/x-icon"
    case jng = "image/x-jng"
    case bmp = "image/x-ms-bmp"
    case svg = "image/svg+xml"
    case webp = "image/webp"
    case woff = "application/font-woff"
    case jar = "application/java-archive"
    case json = "application/json"
    case hqx = "application/mac-binhex40"
    case doc = "application/msword"
    case pdf = "application/pdf"
    case ps = "application/postscript"
    case rtf = "application/rtf"
    case m3u8 = "application/vnd.apple.mpegurl"
    case xls = "application/vnd.ms-excel"
    case eot = "application/vnd.ms-fontobject"
    case ppt = "application/vnd.ms-powerpoint"
    case wmlc = "application/vnd.wap.wmlc"
    case kml = "application/vnd.google-earth.kml+xml"
    case kmz = "application/vnd.google-earth.kmz"
    case sevenz = "application/x-7z-compressed"
    case cco = "application/x-cocoa"
    case jardiff = "application/x-java-archive-diff"
    case jnlp = "application/x-java-jnlp-file"
    case run = "application/x-makeself"
    case pl = "application/x-perl"
    case prc = "application/x-pilot"
    case rar = "application/x-rar-compressed"
    case rpm = "application/x-redhat-package-manager"
    case sea = "application/x-sea"
    case swf = "application/x-shockwave-flash"
    case sit = "application/x-stuffit"
    case tcl = "application/x-tcl"
    case crt = "application/x-x509-ca-cert"
    case xpi = "application/x-xpinstall"
    case xhtml = "application/xhtml+xml"
    case xspf = "application/xspf+xml"
    case zip = "application/zip"
    case bin = "application/octet-stream"
    case docx = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    case xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case pptx = "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    case midi = "audio/midi"
    case mp3 = "audio/mpeg"
    case ogg = "audio/ogg"
    case m4a = "audio/x-m4a"
    case ra = "audio/x-realaudio"
    case threegpp = "video/3gpp"
    case ts = "video/mp2t"
    case mp4 = "video/mp4"
    case mpeg = "video/mpeg"
    case mov = "video/quicktime"
    case webm = "video/webm"
    case flv = "video/x-flv"
    case m4v = "video/x-m4v"
    case mng = "video/x-mng"
    case asf = "video/x-ms-asf"
    case wmv = "video/x-ms-wmv"
    case avi = "video/x-msvideo"
}

internal let mimeTypes = [
	"html": "text/html",
	"htm": "text/html",
	"shtml": "text/html",
	"css": "text/css",
	"xml": "text/xml",
	"gif": "image/gif",
	"jpeg": "image/jpeg",
	"jpg": "image/jpeg",
	"js": "application/javascript",
	"atom": "application/atom+xml",
	"rss": "application/rss+xml",
	"mml": "text/mathml",
	"txt": "text/plain",
	"jad": "text/vnd.sun.j2me.app-descriptor",
	"wml": "text/vnd.wap.wml",
	"htc": "text/x-component",
	"md": "text/markdown",
	"png": "image/png",
	"tif": "image/tiff",
	"tiff": "image/tiff",
	"wbmp": "image/vnd.wap.wbmp",
	"ico": "image/x-icon",
	"jng": "image/x-jng",
	"bmp": "image/x-ms-bmp",
	"svg": "image/svg+xml",
	"svgz": "image/svg+xml",
	"webp": "image/webp",
	"woff": "application/font-woff",
	"jar": "application/java-archive",
	"war": "application/java-archive",
	"ear": "application/java-archive",
	"json": "application/json",
	"hqx": "application/mac-binhex40",
	"doc": "application/msword",
	"pdf": "application/pdf",
	"ps": "application/postscript",
	"eps": "application/postscript",
	"ai": "application/postscript",
	"rtf": "application/rtf",
	"m3u8": "application/vnd.apple.mpegurl",
	"xls": "application/vnd.ms-excel",
	"eot": "application/vnd.ms-fontobject",
	"ppt": "application/vnd.ms-powerpoint",
	"wmlc": "application/vnd.wap.wmlc",
	"kml": "application/vnd.google-earth.kml+xml",
	"kmz": "application/vnd.google-earth.kmz",
	"7z": "application/x-7z-compressed",
	"cco": "application/x-cocoa",
	"jardiff": "application/x-java-archive-diff",
	"jnlp": "application/x-java-jnlp-file",
	"run": "application/x-makeself",
	"pl": "application/x-perl",
	"pm": "application/x-perl",
	"prc": "application/x-pilot",
	"pdb": "application/x-pilot",
	"rar": "application/x-rar-compressed",
	"rpm": "application/x-redhat-package-manager",
	"sea": "application/x-sea",
	"swf": "application/x-shockwave-flash",
	"sit": "application/x-stuffit",
	"tcl": "application/x-tcl",
	"tk": "application/x-tcl",
	"der": "application/x-x509-ca-cert",
	"pem": "application/x-x509-ca-cert",
	"crt": "application/x-x509-ca-cert",
	"xpi": "application/x-xpinstall",
	"xhtml": "application/xhtml+xml",
	"xspf": "application/xspf+xml",
	"zip": "application/zip",
	"bin": "application/octet-stream",
	"exe": "application/octet-stream",
	"dll": "application/octet-stream",
	"deb": "application/octet-stream",
	"dmg": "application/octet-stream",
	"iso": "application/octet-stream",
	"img": "application/octet-stream",
	"msi": "application/octet-stream",
	"msp": "application/octet-stream",
	"msm": "application/octet-stream",
	"docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
	"xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
	"pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
	"mid": "audio/midi",
	"midi": "audio/midi",
	"kar": "audio/midi",
	"mp3": "audio/mpeg",
	"ogg": "audio/ogg",
	"m4a": "audio/x-m4a",
	"ra": "audio/x-realaudio",
	"3gpp": "video/3gpp",
	"3gp": "video/3gpp",
	"ts": "video/mp2t",
	"mp4": "video/mp4",
	"mpeg": "video/mpeg",
	"mpg": "video/mpeg",
	"mov": "video/quicktime",
	"webm": "video/webm",
	"flv": "video/x-flv",
	"m4v": "video/x-m4v",
	"mng": "video/x-mng",
	"asx": "video/x-ms-asf",
	"asf": "video/x-ms-asf",
	"wmv": "video/x-ms-wmv",
	"avi": "video/x-msvideo"
]

internal func MimeType(ext: String?) -> String {
    if ext != nil && mimeTypes.contains(where: { $0.0 == ext!.lowercased() }) {
		return mimeTypes[ext!.lowercased()]!
	}
	return DEFAULT_MIME_TYPE
}

extension NSURL {
	func mimeType() -> String {
		return MimeType(ext: self.pathExtension)
	}
}


extension NSString {
	func mimeType() -> String {
		return MimeType(ext: self.pathExtension)
	}
}

extension String {
	func mimeType() -> String {
		return (self as NSString).mimeType()
	}
}
