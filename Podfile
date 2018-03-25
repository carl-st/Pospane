# Uncomment the next line to define a global platform for your project


def sharedPods
  pod 'SwiftLint'
end

target 'Pospane' do
platform :ios, ' 11.0'
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Pospane
  pod 'SIAlertView'
  pod 'TPKeyboardAvoiding', '~> 1.3'
  pod 'Font-Awesome-Swift', '~> 1.7.2'
  sharedPods

  target 'PospaneTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'PospaneUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'PospaneWatch' do
platform :watchos, '4.0'
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PospaneWatch
  sharedPods
end

target 'PospaneWatch Extension' do
platform :watchos, '4.0'
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for PospaneWatch Extension
  sharedPods

end
