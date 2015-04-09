module SessionHelpers

  feature 'User signs in' do
    before(:each) do
      User.create(email: 'a@a.com',
                  password: 'test',
                  password_confirmation: 'test')
    end

    scenario 'with correct credentials' do
      visit '/'
      expect(page).not_to have_content('Welcome, a@a.com')
      sign_in('a@a.com', 'test')
      expect(page).to have_content('Welcome, a@a.com')
    end

    scenario 'with incorrect credentials' do
      visit '/'
      expect(page).not_to have_content('Welcome, a@a.com')
      sign_in('a@a.com', 'wrong')
      expect(page).not_to have_content('Welcome, a@a.com')
    end

    def sign_in(email, password)
      visit '/sessions/new'
      fill_in 'email', with: email
      fill_in 'password', with: password
      click_button 'Sign in'
    end
  end

  feature 'User signs out' do

    before(:each) do
      User.create(email: 'a@a.com',
                  password: 'test',
                  password_confirmation: 'test')
    end

    scenario 'while being signed in' do
      sign_in('a@a.com', 'test')
      click_button 'Sign out'
      expect(page).to have_content('Good bye!')
      expect(page).not_to have_content('Welcome, a@a.com')
    end

    def sign_in(email, password)
      visit '/sessions/new'
      fill_in 'email', with: email
      fill_in 'password', with: password
      click_button 'Sign in'
    end

  end
end
