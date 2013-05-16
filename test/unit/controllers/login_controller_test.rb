require 'test_helper'

describe LoginController do
  let(:username) { 'admin' }
  let(:password) { 'admin' }

  describe "#index" do

    context "no return_url parameter" do
      before { get :index }
      it { response.must_be :success? }
    end

    context "logout notice is displayed" do
      before { get :index, :notice => 'logout' }
      it { response.must_be :success? }
      it { flash[:success].wont_be_nil }
    end

    context "expired notice is displayed" do
      before { get :index, :notice => 'expired' }
      it { response.must_be :success? }
      it { flash[:warning].wont_be_nil }
    end

    context "return_url set" do
      let(:url) { 'https://localhost' }
      before { get :index, :return_url => url }

      it "should store url to session" do
        session[:return_url].must_equal(url)
      end
    end

    context "user is logged in" do
      let(:url) { 'https://localhost/katello/some/action' }
      before { session[:username] = 'admin' }

      context "return_url parameter provided" do
        before { get :index, :return_url => url }

        it { response.must_be :redirect? }
        it { response.redirect_url.must_include(url) }
      end

      context "cookie is not set" do
        before do
          cookies.delete(:username)
          get :index
        end

        it { cookies[:username].must_equal username }
        it { response.must_be :redirect? }
      end
    end
  end

  describe "#login" do
    context "auth successful" do
      before do
        stub_request(:get, "https://localhost/katello/authenticate?password=#{password}&username=#{username}").
            to_return(:status => 200, :body => "", :headers => {})
        Configuration.config.backends.stub :enabled, [:katello] do
          post :login, :username => username, :password => password
        end
      end

      context "without return url" do
        it { response.must_be :redirect? }
        it { session[:username].must_equal(username) }
        it { cookies[:username].must_equal(username) }
      end

      context "with return url in session" do
        let(:url) { 'https://localhost/test' }
        before do
          session[:return_url] = url
          Configuration.config.backends.stub :enabled, [:katello] do
            post :login, :username => username, :password => password
          end
        end

        it { response.redirect_url.must_equal url }
      end
    end

    context "auth failed" do
      before do
        stub_request(:get, "https://localhost/katello/authenticate?password=pass&username=#{username}").
            to_return(:status => 403, :body => "", :headers => {})
        post :login, :username => username, :password => 'pass'
      end

      it { response.must_be :success? }
    end
  end

  describe "#provider" do
    let(:openid_params) { { 'openid.assoc_handle' => '{HMAC-SHA1}{51399cc7}{L/riIQ==}',
                            'openid.claimed_id'   => 'https://localhost/user/admin',
                            'openid.identity'     => 'https://localhost/user/admin',
                            'openid.mode'         => 'checkid_setup',
                            'openid.ns'           => 'http://specs.openid.net/auth/2.0',
                            'openid.ns.sreg'      => 'http://openid.net/extensions/sreg/1.1',
                            'openid.realm'        => 'https://localhost',
                            'openid.return_to'    => 'https://localhost/katello/' }
    }

    context "not logged user" do
      before do
        get :provider, openid_params
      end

      it "should redirect to login form" do
        response.must_be :redirect?
        response.redirect_url.must_include(root_path(:return_url => 'https://localhost/katello/'))
      end
    end

    context "user is logged in already" do
      before { session[:username] = username }

      context "user has no cookie" do
        before { get :provider, openid_params }

        it "should login user" do
          response.must_be :redirect?
          cookies[:username].must_equal username
          response.redirect_url.must_include('https://localhost/katello/')
        end
      end

      context "user has cookie with same username as he is logged in" do
        before do
          cookies[:username] = username
          get :provider, openid_params
        end

        it "should login user" do
          response.must_be :redirect?
          cookies[:username].must_equal username
          response.redirect_url.must_include('https://localhost/katello/')
          response.redirect_url.must_include('id_res') # success
        end
      end

      context "user has cookie with different username than he is logged in" do
        before do
          get :provider, openid_params.merge('openid.identity'   => 'https://localhost/user/ares',
                                             'openid.calimed_id' => 'https://localhost/user/ares')
        end

        it "fixes cookie and redirects back to relay party" do
          response.must_be :redirect?
          cookies[:username].must_equal username
          response.redirect_url.must_equal('https://localhost/katello/')
          response.redirect_url.wont_include('id_res')
        end
      end

      context "Relay Party not authorized (whitelisted in configuration)" do
        before do
          get :provider, openid_params.merge('openid.realm'     => 'https://mylocalhost',
                                             'openid.return_to' => 'https://mylocalhost')
        end

        it "should redirect to root with error" do
          flash[:error].must_be :present?
          response.must_be :redirect?
        end
      end
    end
  end

  describe "#logout" do
    context "user is logged in" do
      before { session[:username] = username }

      context "user logouts without return url" do
        before { get :logout }

        it { response.must_be :redirect? }
        it { response.redirect_url.must_include root_path(:notice => 'logout') }
        it { session[:username].must_be_nil }
      end

      context "user logouts and sets return url" do
        let(:url) { 'https://localhost/katello/whatever' }
        before { get :logout, :return_url => url }

        it { response.must_be :redirect? }
        it { response.redirect_url.must_include root_path(:notice => 'logout') }
        it { session[:username].must_be_nil }
        it { session[:return_url].must_equal url }
      end
    end
  end
end
