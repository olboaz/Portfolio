
require "test_helper"
require "ostruct"
require "minitest/mock"

class ContactVisitorInfoServiceTest < ActiveSupport::TestCase
  test "une adresse locale ne declenche pas de geolocalisation" do
    request = OpenStruct.new(
      remote_ip: "::1",
      user_agent: "Navigateur de test",
      referer: nil,
      headers: { "Accept-Language" => "fr-FR" }
    )

    ContactVisitorInfoService.stub(:lookup_geo, {}) do
      ContactVisitorInfoService.stub(:resolve_hostname, "localhost") do
        info = ContactVisitorInfoService.call(request)

        assert_equal "::1", info[:ip]
        assert_equal "Inconnu", info[:country]
        assert_equal "??", info[:country_code]
        assert_equal "localhost", info[:hostname]
        assert_equal "fr-FR", info[:language]
      end
    end
  end

  test "une erreur de geolocalisation retourne un resultat vide" do
    Net::HTTP.stub(:start, ->(*) { raise IOError, "API indisponible" }) do
      result = ContactVisitorInfoService.send(:lookup_geo, "8.8.8.8")

      assert_equal({}, result)
    end
  end

  test "une adresse locale est ignoree par GeoIP" do
    Net::HTTP.stub(:start, ->(*) { flunk "Aucun appel HTTP attendu" }) do
      assert_equal(
        {},
        ContactVisitorInfoService.send(:lookup_geo, "127.0.0.1")
      )

      assert_equal(
        {},
        ContactVisitorInfoService.send(:lookup_geo, "::1")
      )
    end
  end

  test "une erreur inattendue du service est propagee au controleur" do
    request = OpenStruct.new(remote_ip: "8.8.8.8")

    ContactVisitorInfoService.stub(
      :lookup_geo,
      ->(*) { raise RuntimeError, "Erreur inattendue" }
    ) do
      assert_raises(RuntimeError) do
        ContactVisitorInfoService.call(request)
      end
    end
  end

end
