require 'test_helper'

# /communication/shop
class TestShop < Minitest::Test
  include DaVaz::TestCase

  def setup
    browser.visit('/en/personal/work')
    link = browser.link(:name, 'shop')
    link.click
  end

  def test_shopping_cart_calculation_with_publications
    assert_match('/en/communication/shop', browser.url)

    shopping_cart = Proc.new {
      wait_until { browser.table(:id, 'shopping_cart') }[0][0]
    }

    item = browser.text_field(:id, 'article[111]')
    item.set('2')
    item.send_keys(:tab)
    cart = shopping_cart.yield
    rows = wait_until { cart.table(:class, 'shopping-cart-list') }
    assert_equal('Title of ArtObject 111', rows[1][2].text)
    assert_equal('CHF 111.-', rows[1][4].text)
    assert(cart.text.include?('CHF 222.- / $ 176.- / € 132.'))

    item = browser.text_field(:id, 'article[112]')
    item.set('2')
    item.send_keys(:tab)
    cart = shopping_cart.yield
    rows = wait_until { cart.table(:class, 'shopping-cart-list') }
    assert_equal('Title of ArtObject 112', rows[1][2].text)
    assert_equal('CHF 112.-', rows[1][4].text)
    assert(cart.text.include?('CHF 446.- / $ 354.- / € 266.-'))

    item = browser.text_field(:id, 'article[113]')
    item.set('2')
    item.send_keys(:tab)
    cart = shopping_cart.yield
    assert(cart.text.include?('CHF 672.- / $ 534.- / € 400.-'))
    rows = wait_until { cart.table(:class, 'shopping-cart-list') }
    assert_equal('Title of ArtObject 113', rows[1][2].text)
    assert_equal('CHF 113.-', rows[1][4].text)

    rows = wait_until { cart.table(:class, 'shopping-cart-list') }
    assert_equal('Title of ArtObject 113', rows[1][2].text)
    assert_equal('Title of ArtObject 112', rows[2][2].text)
    assert_equal('Title of ArtObject 111', rows[3][2].text)

    link = browser.link(:text, 'Remove all items')
    link.click
  end

  def test_checkout_fails_without_user_info
    assert_match('/en/communication/shop', browser.url)

    item = browser.text_field(:id, 'article[113]')
    item.set('2')
    item.send_keys(:tab)

    item = browser.text_field(:id, 'article[114]')
    item.set('1')
    item.send_keys(:tab)

    link = browser.button(:text, 'Order item(s)')
    link.click

    assert(browser.text.include?(
      'Please fill out the fields that are marked with red.'))

    link = browser.link(:text, 'Remove all items')
    link.click
  end

  def test_checkout_fails_with_validation_error
    assert_match('/en/communication/shop', browser.url)

    item = browser.text_field(:id, 'article[113]')
    item.set('2')
    item.send_keys(:tab)

    item = browser.text_field(:id, 'article[114]')
    item.set('1')
    item.send_keys(:tab)

    browser.text_field(:name, 'name').set('John Smith')
    browser.text_field(:name, 'surname').set('Mr.')
    browser.text_field(:name, 'street').set('Winterthurerstrasse')
    browser.text_field(:name, 'postal_code').set('A')
    browser.text_field(:name, 'city').set('Zürich')
    browser.text_field(:name, 'country').set('Switzerland')
    browser.text_field(:name, 'email').set('john@example.org')

    link = browser.button(:text, 'Order item(s)')
    link.click

    assert(browser.text.include?(
      'Your Postal Code seems to be invalid.'))
    assert(browser.text.include?(
      'Sorry, but your email-address seems to be invalid. Please try again.'))

    link = browser.link(:text, 'Remove all items')
    link.click
  end

  #def test_checkout
  #  @browser.type "article[113]", "2"
  #  @browser.type "article[114]", "2"
  #  sleep 3
  #  assert @browser.is_text_present("CHF 226.-")
  #  @browser.type "article[113]", "4"
  #  @browser.type "article[114]", "0"
  #  sleep 3
  #  assert @browser.is_text_present("CHF 452.-")
  #  assert @browser.is_text_present("CHF 452.- / $ 360.- / € 268.-")
  #  @browser.type "name", "TestName"
  #  @browser.type "surname", "TestSurname"
  #  @browser.type "street", "TestStreet"
  #  @browser.type "postal_code", "TestZip"
  #  @browser.type "city", "TestCity"
  #  @browser.type "country", "TestCountry"
  #  @browser.type "email", "TestEmail"
  #  @browser.click "order_item"
  #  @browser.wait_for_page_to_load "30000"
  #  assert @browser.is_text_present("Your Postal Code seems to be invalid.")
  #  assert @browser.is_text_present("Sorry, but your email-address seems to be invalid. Please try again.")
  #  @browser.type "postal_code", "8888"
  #  @browser.type "email", "mhuggler@ywesee.com"
  #  @browser.click "order_item"
  #  @browser.wait_for_page_to_load "30000"
  #  assert @browser.is_text_present("Your order has been succesfully sent.")
  #end

	#def test_test_shop2
  #  @browser.open "/en/communication/shop"
  #  @browser.wait_for_page_to_load "30000"
  #  @browser.click "link=Title of ArtObject 112"
  #  @browser.wait_for_page_to_load "30000"
  #  assert @browser.is_text_present("Text of ArtObject 112")
  #  @browser.click "paging_next"
  #  @browser.wait_for_page_to_load "30000"
  #  assert @browser.is_text_present("Text of ArtObject 113")
  #  @browser.click "link=Back To Shop"
  #  @browser.wait_for_page_to_load "30000"
  #  assert @browser.is_text_present("Title of ArtObject 114")
  #end
end
