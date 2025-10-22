#!/usr/bin/env python3
"""
Automated Xcode Project Fixer
Adds missing Swift files to the Xcode project
"""

import os
import re
import uuid
import shutil

PROJECT_DIR = "/Users/zachthomas/Desktop/CRM-APP-SWIFT"
PROJECT_FILE = f"{PROJECT_DIR}/TrusendaCRM.xcodeproj/project.pbxproj"

# Files to add
NEW_FILES = [
    ("TrusendaCRM/Core/Storage/ActivityTracker.swift", "ActivityTracker.swift"),
    ("TrusendaCRM/Core/Utilities/ImageCache.swift", "ImageCache.swift"),
    ("TrusendaCRM/Features/Properties/PropertyPhotoGallery.swift", "PropertyPhotoGallery.swift"),
]

def generate_uuid():
    """Generate a unique 24-character hex ID for Xcode"""
    return uuid.uuid4().hex[:24].upper()

def backup_project():
    """Create a backup of the project file"""
    backup_path = f"{PROJECT_FILE}.backup"
    shutil.copy2(PROJECT_FILE, backup_path)
    print(f"✅ Backup created: {backup_path}")

def add_files_to_project():
    """Add files to Xcode project.pbxproj"""
    
    # Read the project file
    with open(PROJECT_FILE, 'r') as f:
        content = f.read()
    
    # Find the PBXFileReference section
    file_ref_section = re.search(r'/\* Begin PBXFileReference section \*/(.*?)/\* End PBXFileReference section \*/', content, re.DOTALL)
    if not file_ref_section:
        print("❌ Cannot find PBXFileReference section")
        return False
    
    # Find the PBXBuildFile section
    build_file_section = re.search(r'/\* Begin PBXBuildFile section \*/(.*?)/\* End PBXBuildFile section \*/', content, re.DOTALL)
    if not build_file_section:
        print("❌ Cannot find PBXBuildFile section")
        return False
    
    # Find the PBXSourcesBuildPhase section
    sources_section = re.search(r'/\* Begin PBXSourcesBuildPhase section \*/(.*?)/\* End PBXSourcesBuildPhase section \*/', content, re.DOTALL)
    if not sources_section:
        print("❌ Cannot find PBXSourcesBuildPhase section")
        return False
    
    # Generate UUIDs for each file
    file_references = []
    build_files = []
    
    for file_path, file_name in NEW_FILES:
        file_ref_id = generate_uuid()
        build_file_id = generate_uuid()
        
        # Create file reference entry
        file_ref_entry = f"\t\t{file_ref_id} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = \"<group>\"; }};\n"
        file_references.append((file_ref_id, file_ref_entry))
        
        # Create build file entry
        build_file_entry = f"\t\t{build_file_id} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* {file_name} */; }};\n"
        build_files.append((build_file_id, build_file_entry))
    
    # Add file references
    insertion_point = content.find("/* End PBXFileReference section */")
    for _, entry in file_references:
        content = content[:insertion_point] + entry + content[insertion_point:]
        insertion_point += len(entry)
    
    print(f"✅ Added {len(file_references)} file references")
    
    # Add build files
    insertion_point = content.find("/* End PBXBuildFile section */")
    for _, entry in build_files:
        content = content[:insertion_point] + entry + content[insertion_point:]
        insertion_point += len(entry)
    
    print(f"✅ Added {len(build_files)} build file entries")
    
    # Add to sources build phase (find the files array)
    sources_match = re.search(r'(buildPhases = \([\s\S]*?files = \()([\s\S]*?)(\);)', content)
    if sources_match:
        files_section = sources_match.group(2)
        for build_id, _ in build_files:
            file_name = [name for _, name in NEW_FILES][build_files.index((build_id, _))]
            new_entry = f"\n\t\t\t\t{build_id} /* {file_name} in Sources */,"
            files_section += new_entry
        
        content = content[:sources_match.start(2)] + files_section + content[sources_match.end(2):]
        print(f"✅ Added files to Sources build phase")
    
    # Write back
    with open(PROJECT_FILE, 'w') as f:
        f.write(content)
    
    return True

def main():
    print("🔧 Xcode Project Fixer")
    print("=" * 50)
    
    # Check if project file exists
    if not os.path.exists(PROJECT_FILE):
        print(f"❌ Project file not found: {PROJECT_FILE}")
        return 1
    
    # Check if new files exist
    print("\n📋 Checking files...")
    for file_path, file_name in NEW_FILES:
        full_path = os.path.join(PROJECT_DIR, file_path)
        if os.path.exists(full_path):
            print(f"✅ {file_name}")
        else:
            print(f"❌ {file_name} not found at {full_path}")
            return 1
    
    # Backup
    print("\n💾 Creating backup...")
    backup_project()
    
    # Add files
    print("\n🔨 Modifying project file...")
    if add_files_to_project():
        print("\n✅ SUCCESS! Files added to project")
        print("\n🎯 Next steps:")
        print("   1. Open TrusendaCRM.xcodeproj in Xcode")
        print("   2. Press Cmd+B to build")
        print("   3. Should build successfully!")
        return 0
    else:
        print("\n❌ FAILED to modify project")
        print("   Restoring backup...")
        shutil.copy2(f"{PROJECT_FILE}.backup", PROJECT_FILE)
        return 1

if __name__ == "__main__":
    exit(main())

