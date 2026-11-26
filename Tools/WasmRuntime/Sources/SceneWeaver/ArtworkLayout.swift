import SwiftUI
public enum ArtworkLayout {
 public static func rect(width:CGFloat,horizon:CGFloat,aspectRatio:CGFloat=1.5,overscan:CGFloat=1.12,motion:CGFloat=0,depth:CGFloat=1)->CGRect{
 let w=max(0,width)*max(1,overscan),h=w/max(0.01,aspectRatio)
 return CGRect(x:(max(0,width)-w)/2+motion*max(0,width)*0.0015*depth,y:horizon-h,width:w,height:h)
 }
}
