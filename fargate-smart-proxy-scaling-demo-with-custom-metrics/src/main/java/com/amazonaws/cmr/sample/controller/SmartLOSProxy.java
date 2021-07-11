package com.amazonaws.cmr.sample.controller;

import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("los")
public class SmartLOSProxy {

    @Autowired
    private MeterRegistry meterRegistry;

    @Autowired
    RestTemplate restTemplate;

    @Value("${BACKEND_URL}")
    private String backendUrl;

    @GetMapping(path = "/{poi}", produces = "application/json")
    public ResponseEntity<String> getPOI(@PathVariable String poi) {
        meterRegistry.counter("requests_getPOI_total").increment();

        ResponseEntity<String> response = restTemplate.getForEntity(backendUrl + "/los/" + poi, String.class);
        HttpStatus status = response.getStatusCode();
        HttpHeaders headers = response.getHeaders();

        HttpHeaders copy = HttpHeaders.writableHttpHeaders(headers);
        copy.add("Custom-Header", "smart-proxy");

        return new ResponseEntity<String>(
                response.getBody(),
                copy,
                status);
    }
}