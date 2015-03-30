source 'https://github.com/CocoaPods/Specs.git'

def vendors

pod "PromiseKit"      

end
def testing
   
   pod 'Expecta', '~> 0.2.4'
   pod 'OCMock', '~> 3.1'
    
end

workspace 'iTunesConnector.xcworkspace'


target 'iTunesConnector' , :exclusive => true do
    xcodeproj 'iTunesConnector.xcodeproj'
    
    vendors     
end

target 'iTunesConnector Test' , :exclusive => true do
    xcodeproj 'iTunesConnector.xcodeproj'
    
    testing     
end