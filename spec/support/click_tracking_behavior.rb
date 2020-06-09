shared_examples_for 'a successful click request' do
  it 'is a successful request' do
    post endpoint, params: valid_params

    expect(response.successful?).to be_truthy
  end

  it 'returns a blank body' do
    post endpoint, params: valid_params

    expect(response.body).to eq('')
  end

  it 'sends the expected params to the click model' do
    expect(click_model).to receive(:new).with(expected_params).and_call_original

    post endpoint, params: valid_params
  end

  it 'logs a click' do
    allow(click_model).to receive(:new).and_return(click_mock)
    allow(click_mock).to receive(:valid?).and_return(true)

    post endpoint, params: valid_params

    expect(click_mock).to have_received(:log)
  end
end

shared_examples_for 'an unsuccessful click request' do
  it 'returns a 400' do
    post endpoint, params: invalid_params

    expect(response.status).to eq 400
  end

  it 'has the expected error message' do
    post endpoint, params: invalid_params

    expect(response.body).to eq(expected_error_msg)
  end

  it 'does not log a click' do
    allow(click_model).to receive(:new).and_return click_mock
    allow(click_mock).to receive(:valid?).and_return(false)
    allow(click_mock).to receive_message_chain(:errors, :full_messages).
      and_return(['mock error'])

    post endpoint, params: invalid_params

    expect(click_mock).not_to have_received(:log)
  end
end

shared_examples_for 'does not accept GET requests' do
  it 'returns a redirect' do
    get endpoint, params: valid_params

    expect(response.status).to eq 302
  end
end

shared_examples_for 'drops urls with invalid utf-8' do
  it 'get thrown away as nil' do
    valid_params['url'] = 'https://example.com/wymiana+teflon%F3w'

    post endpoint, params: valid_params

    expect(response.success?).to be(false)
    expect(response.body).to eq "[\"Url can't be blank\"]"
  end
end
