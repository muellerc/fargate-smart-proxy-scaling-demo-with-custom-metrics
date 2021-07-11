import io.gatling.core.Predef._
import io.gatling.http.Predef._
import scala.concurrent.duration._

class LoadTest extends Simulation {

  val siteUrl = System.getProperty("BASE_URL");

  val httpProtocol = http
    .baseUrl(siteUrl)
    .acceptHeader("application/json")
    .doNotTrackHeader("1")

  val scn = scenario("LoadTest")
    .exec(
      http("get_poi")
        .get("/los/1")
        .header("Accept", "application/json")
    )

  setUp(
    scn.inject(
      incrementConcurrentUsers(10)
        .times(50)
        .eachLevelLasting(300)
        .separatedByRampsLasting(60)
        .startingFrom(10)
    ).protocols(httpProtocol)
  )
}
