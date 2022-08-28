require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: 'Exemplu', email: 'user@example.com',
                    password: "foobar", password_confirmation: "foobar")
  end

  test 'name should be present' do
    @user.name = ''
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = ''
    assert_not @user.valid?
  end

  test 'name should be short' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should be short' do
    @user.email = 'a' * 500 + '@exemplu.org'
    assert_not @user.valid?
  end

  test 'validation rejects invalid addresses' do
    invalid_addresses = %w[example.notok.com example@ok,com example example@ok]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid? "#{invalid_address} should be invalid"
    end
  end

  test 'no email duplicates' do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'emails are saved as lowercase' do
    @user.email = 'uSer@eXamPlE.com'
    @user.save
    assert_equal 'user@example.com', @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end
end
