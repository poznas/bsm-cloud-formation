# BSM 3.0

Brief description of what the _**B**ulgarian **S**chool of **M**agic_ actually is can be found [here](https://github.com/poznas/BSM-App/blob/master/README.md)
and [here on short fragment of a film](https://youtu.be/vgX0AprByQQ) documenting a pilot camp 2017. 
There is also a [tiny clip](https://www.youtube.com/watch?v=sTO2uCKfo1Y) from 2018.

For all the years the application has not changed its main part which is the **mission rating system**

![BSM-rating-system](https://user-images.githubusercontent.com/23015353/63798972-65b9a800-c90b-11e9-9314-3807479c3160.png)

## Previous application generations

* [2017 Android & Firebase](https://github.com/poznas/BSM-App) 
   * detailed scoreboards
   * mission rating system
   * 3 other admin ways to insert points
   * facebook like news feed
   
* [2018 reimplementation as MVP](https://github.com/poznas/Rx-BSM)

   + \+ badges 
   + \+ players ranking
   + \+ user manager for admin
   + \+ game state controller for admin
   
# 2019 redesign

![](https://user-images.githubusercontent.com/23015353/57571460-ead98980-740e-11e9-8a22-a4a4fc0d525c.png)

Android replaced with React Native. Firebase changed to Spring Boot apps network hosted on AWS
* all the **core business logic moved** from client app to backend
* after 2 years, the **iOS** application client **version** finally appeared
* more **cloud agnostic** solution
  
http://bsm.pub/api/swagger-ui.html
  
## Related repositories
* [current one](https://github.com/poznas/bsm-cloud-formation) contains all cloud formation templates, config files, installation scripts and lambda code. 
With all of those, whole BSM 3.0 backend structure can be recreated from zero via cloud formation. 
Same process is used for rolling deployment
* [react native client app](https://github.com/poznas/bsm-mobile-client) 
* [ingress controller with all business logic](https://github.com/poznas/bsm-web-api) - breaks the principles of microservices, but at least it's a cheaper solution
* [dictionary service](https://github.com/poznas/bsm-dictionary) - simple literals warehouse
* [notifier service]() - not yet created

