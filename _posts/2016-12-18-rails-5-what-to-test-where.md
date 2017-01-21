---
layout: post
title: "Rails 5: What to test where?"
category: Tech
tags:
  - rails 5
  - rspec
  - what to test
  - test types
  - test architecture
---

Rails 5 has different types of tests and RSpec adds its options. This post offers my take on feature specs, *request specs*, *controller specs* and unit tests - where to test what.

For me it is quite clear what to do with the tests in two ends: feature specs and unit tests. Feature tests are the highest level integration tests that behave like the user would through a browser. You interact with the page and make assertions against the resulting page. They are slow and they shouldn't be very detailed. *Unit tests* are the other end of the spectrum - you instantiate objects directly, often passing in stubbed/mocked dependencies and make assertions against return values. These tests are very fast, detailed and of plenty.

My confusion and reason for this post arose from trying to decide how to approach the remaining two: *request specs* and *controller specs*. They are quite similar but also somewhat different. I will provide short answer and then explain each in greater detail.

## Controller vs Request specs: use only request specs

As the *controller specs* and *requests specs* are quite similar, I have chosen to only implement *request specs*. The main difference is that I put them under `spec/controllers` and tag them with `:request`.

I like to use 3 types of tests. They are ordered from higher level to lower:

1. Feature specs in `spec/features`
2. Request specs in `spec/requests`
3. Unit tests in other spec folders e.g. `spec/models`, `spec/services`, `spec/...`

Below are more details on each type, which capabilities are available to them, how to set up input and what to assert.

## Feature specs

The tests in `spec/features` use capybara to interact with the application as an ordinary user.

### Capabilities available

Example feature spec:

```ruby
describe 'General project info' do
  it 'shows health of a project' do
    visit '/'
    fill_in 'Project', with: 'rails/rails'
    click 'Diagnose'
    expect(page).to have_content 'Status: very active'
  end
end
```

Selection of useful assertions:

- `expect(page).to have_content 'Some text'`
- `expect(page).to have_link 'Next'`
- See all at [Capybara Rspec matchers docs](http://www.rubydoc.info/github/jnicklas/capybara/master/Capybara/RSpecMatchers)

## Request specs

As said, I tend to use *request specs* in place of *controller specs*. The description in [Rails guides](http://edgeguides.rubyonrails.org/testing.html#functional-tests-for-your-controllers) states that controller specs inherit from `ActionDispatch::IntegrationTest`. This is the same with *request specs*. The main difference is that the methods for requesting (*get post put patch ...*):

- request specs: **path** (e.g. `get '/posts/1`)
- controller specs: **controller action name** (e.g. `get posts_path(post)`)

What separates *request specs* from *controller specs* is that they don't allow using Capybara's methods (_visit_, _page_, etc).

```ruby
describe 'GET /rails/rails' do
  it 'imports data' do
    expect { get '/rails/rails' }.to change(Project, :count)
  end

  it 'returns summary' do

  end
end
```

### Capabilities available

Selection of useful assertions:

Rspec:
- `expect(response).to eq :success`
- `expect(path).to eq '/welcome`
- `expect(flash[:notice]).to eq 'Welcome david!'`

Minitest:
- `assert_response :success`
- `assert_equal '/welcome', path`
- `assert_equal 'Welcome david!', flash[:notice]`


## References

1. [Changes to test controllers in Rails 5](http://blog.bigbinary.com/2016/04/19/changes-to-test-controllers-in-rails-5.html)
2. [Better Rails 5 API Controller Tests with RSpec Shared Examples](http://www.thegreatcodeadventure.com/better-rails-5-api-controller-tests-with-rspec-shared-examples/)
3. [Rails API Testing Best Practices](http://matthewlehner.net/rails-api-testing-guidelines/)
4. [Replacing RSpec controller specs, part 1: Request specs](https://everydayrails.com/2016/08/29/replace-rspec-controller-tests.html)
5. [RSpec Rails 3.5 Request Spec](https://www.relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec)
6. [ActionDispatch::IntegrationTest docs](http://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)



