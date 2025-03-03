---
title: "SpringDoc 전환기"
categories: java
tags: spring mvc swagger springdoc springfox
last_modified_at: 2025-02-27T15:00:00+09:00
#classes: wide
toc: true
toc_sticky: true
---

> 내 프로젝트는 `Spring 5 MVC` 프로젝트이고 `SpringFox`를 사용중이었다.  
> `Spring 6`로 변환 중 `SpringFox`는 더이상 사용할 수 없다는걸 알게되었다.  
> 어쩔 수 없이 `SpringDoc`으로 변환하는 도중 알게 된 점을 정리하고자 한다.

## `SpringDoc` 사용중 고려해야 할 사항

### `springdoc-openapi-starter-webmvc-ui:2.2.0`은 `SpringBoot`가 필요하다

좀 더 정확하게 말하자면 `SpringBoot`의 일부 Dependency가 필요하다

- `springdoc-openapi-starter-webmvc-ui`
  - spring-boot-starter
    - spring-boot
    - spring-boot-autoconfigure
    - spring-boot-starter-logging
- `spring-boot-starter-validation`
  - spring-boot-autoconfigure

SpringBoot가 아닌 구조에서 위의 Dependency들을 추가한다는게 조금 꺼림찍하게 느껴졌다.

일단 되든안되든 어떤 부작용이 나타날지 모르니 시도해보기로 했다.

## 변환 시작 🍟🍟

### 1. Dependency 교체

SpringFox를 제거하고 SpringDoc을 추가했다.

```xml
<!--swagger -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.2.0</version>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
    <version>3.1.2</version>
</dependency>

<!--dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger2</artifactId>
    <version>2.8.0</version>
    <exclusions>
        <exclusion>
            <artifactId>spring-aop</artifactId>
            <groupId>org.springframework</groupId>
        </exclusion>
        <exclusion>
            <artifactId>spring-context</artifactId>
            <groupId>org.springframework</groupId>
        </exclusion>
    </exclusions>
</dependency>
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger-ui</artifactId>
    <version>2.8.0</version>
</dependency>
```

### 2. Annotation 교체

Controller와 DTO에서 사용했던 SpringFox만의 Annotation을 교체해야 했다.

#### Controller

|SpringFox|SpringDoc|비고|
|-----|----|---|
|@Api(value = "SampleController", tags = "샘플")|@Tag(name = "SampleController", description = "샘플")|  |
|@ApiOperation(value = "샘플 목록 조회", notes="[{\"test\":\"test1\"}]")|@Operation(summary = "샘플 목록 조회", description="[{\"test\":\"test1\"}]")|  |
|@ApiParam(value = "검색조건", required = true)|@Parameter(description = "검색조건", required = true)| Querystring |
|@ApiParam(value = "검색조건", required = true)|@Parameter(description = "검색조건", in = ParameterIn.PATH, required = true)| PathVariable |
|@ApiParam(value = "검색조건", required = true) | @ParameterObject | ModelAttribute |
|@ApiParam(value = "데이터", required = true) | - | RequestBody |
|@ApiImplicitParams({@ApiImplicitParam(name = "projectCd", value = "프로젝트코드", paramType = "path", required = true)})|@Parameters({@Parameter(name = "projectCd", description = "프로젝트코드", in = ParameterIn.PATH, required = true)})||
|@ApiOperation(value = "게시판 첨부파일 업로드", produces = MediaType.MULTIPART_FORM_DATA_VALUE)  @ApiImplicitParams({@ApiImplicitParam(name = "attachCd", value = "첨부파일코드", paramType = "form")})|@Operation(summary = "게시판 첨부파일 업로드",requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(content = @Content(mediaType = MediaType.MULTIPART_FORM_DATA_VALUE)))  @Parameters({@Parameter(name = "attachCd", description = "첨부파일코드", in = ParameterIn.QUERY)})|_확인필요_|
|@ApiIgnore|@Hidden||

#### DTO

|SpringFox|SpringDoc|비고|
|-----|----|---|
|@ApiModelProperty(value = "부서코드", position = 1, example = "D0001", readOnly=true)|@Schema(description = "부서코드", example = "D0001", accessMode = AccessMode.READ_ONLY)||
|@ApiModelProperty(value = "부서코드", position = 1, example = "D0001", nullable=true)|@Schema(description = "부서코드", example = "D0001", allowEmptyValue = true)||
|@ApiModelProperty(value = "등록일자(시작)", position = 4, dataType = "yyyyMMdd")|@Schema(description = "등록일자(시작)", type = "string", pattern = "yyyyMMdd")||
|@ApiModelProperty(value = "최종로그인일시", position = 25)|@Schema(description = "최종로그인일시", example = "yyyy-MM-dd HH:mm:ss.SSS", type = "string", pattern = "yyyy-MM-dd HH:mm:ss.SSS")|LocalDateTime|
|@ApiModelProperty(value = "등록일시", position = 91, example = "yyyy-MM-dd HH:mm:ss.SSS", dataType = "yyyy-MM-dd HH:mm:ss.SSS", readOnly = true)|@Schema(description = "등록일시", example = "yyyy-MM-dd HH:mm:ss.SSS", type = "string", pattern = "yyyy-MM-dd HH:mm:ss.SSS", accessMode = AccessMode.READ_ONLY)|LocalDateTime|
|@ApiModelProperty(hidden = true)|@Schema(hidden = true)||


### 3. SwaggerConfig 수정

기존에 사용하던 SpringFox의 설정을 SwaggerConfig.java에서 하고있었다.

1. 기본 Consume, Produce의 MediaType JSON 고정
2. 기본 Header 지정
  - Authorization
  - Content-Type
  - Accept-Language
  - X-Client-Id (custom header)

```java
import java.time.Duration;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.builders.RequestParameterBuilder;
import springfox.documentation.builders.ResponseBuilder;
import springfox.documentation.oas.annotations.EnableOpenApi;
import springfox.documentation.schema.ScalarType;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Contact;
import springfox.documentation.service.ParameterType;
import springfox.documentation.service.RequestParameter;
import springfox.documentation.service.Response;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;

/**
 * Swagger 설정.
 *
 * @author : glorial
 * @since : 1.0
 */
@EnableOpenApi
public class SwaggerConfig {

    @Value("#{custom['swagger.use.yn'] ?: 'N'}")
    private String swaggerUseYn;

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * Swagger 설정.
     *
     * @return Swagger 설정 정보
     */
    @Bean
    public Docket customImplementation() {
        return new Docket(DocumentationType.SWAGGER_2)
            .useDefaultResponseMessages(false)  // 기존적인 응답메시지 미사용
            .globalResponses(HttpMethod.GET, getArrayList()) // 정의한 응답메시지 사용
            .globalResponses(HttpMethod.POST, getArrayList())
            .globalResponses(HttpMethod.PUT, getArrayList())
            .globalResponses(HttpMethod.PATCH, getArrayList())
            .globalResponses(HttpMethod.DELETE, getArrayList())
            .consumes(getConsumeContentTypes())
            .produces(getProduceContentTypes())
            .apiInfo(getApiInfo())
            .select()
            .apis(RequestHandlerSelectors.basePackage("kr.co"))
            .paths(PathSelectors.ant("/api/**"))
            .build()
            .globalRequestParameters(jwtParam())
            .enable("Y".equals(swaggerUseYn));
    }

    /**
     * Swagger UI 에서 보여지는 API 정보.
     *
     * @return API 정보
     */
    public ApiInfo getApiInfo() {
        //noinspection HttpUrlsUsage
        return new ApiInfo("My REST API Documentation",
            "My REST Api Documentation",
            "1.0",
            "https://www.glorial.co.kr",
            new Contact("Glorial", "https://www.glorial.co.kr", "glorial@glorial.co.kr"),
            "Apache 2.0", "http://www.apache.org/licenses/LICENSE-2.0",
            new ArrayList<>());
    }

    private ArrayList<Response> getArrayList() {
        ArrayList<Response> lists = new ArrayList<>();
        lists.add(new ResponseBuilder().code(HttpStatus.INTERNAL_SERVER_ERROR.name()).description("500 ERROR").build());
        lists.add(new ResponseBuilder().code(HttpStatus.FORBIDDEN.name()).description("403 ERROR").build());
        lists.add(new ResponseBuilder().code(HttpStatus.UNAUTHORIZED.name()).description("401 ERROR").build());
        return lists;
    }

    private Set<String> getConsumeContentTypes() {
        Set<String> consumes = new HashSet<>();
        consumes.add(MediaType.APPLICATION_JSON_VALUE);
        return consumes;
    }

    private Set<String> getProduceContentTypes() {
        Set<String> produces = new HashSet<>();
        produces.add(MediaType.APPLICATION_JSON_VALUE);
        return produces;
    }

    private List<RequestParameter> jwtParam() {
        RequestParameter parameter = new RequestParameterBuilder()
            .name(JwtUtil.HEADER_AUTHORIZATION)
            .query(q -> q.model(m -> m.scalarModel(ScalarType.STRING))
                         .defaultValue(JwtUtil.TOKEN_TYPE_BEARER + " " + createSwaggerToken()))
            .in(ParameterType.HEADER)
            .required(true)
            .build();

        RequestParameter contentParam = new RequestParameterBuilder()
            .name(HttpHeaders.CONTENT_TYPE)
            .query(q -> q.model(m -> m.scalarModel(ScalarType.STRING))
                         .defaultValue(MediaType.APPLICATION_JSON_VALUE))
            .in(ParameterType.HEADER)
            .required(true)
            .build();

        RequestParameter langParam = new RequestParameterBuilder()
            .name(HttpHeaders.ACCEPT_LANGUAGE)
            .query(q -> q.model(m -> m.scalarModel(ScalarType.STRING))
                         .defaultValue(Locale.KOREAN.toString()))
            .in(ParameterType.HEADER)
            .required(true)
            .build();

        RequestParameter clientId = new RequestParameterBuilder()
            .name(JwtUtil.HEADER_X_CLIENT_ID)
            .query(q -> q.model(m -> m.scalarModel(ScalarType.STRING))
                         .defaultValue("swaggertest"))
            .in(ParameterType.HEADER)
            .required(true)
            .build();

        return Arrays.asList(parameter, contentParam, langParam, clientId);
    }

    private String createSwaggerToken() {
        if (!"Y".equals(swaggerUseYn)) {
            return StringUtils.EMPTY;
        }

        String userNm = "admin";
        long expiredTerm = Duration.ofDays(5).toMillis();  // 5일
        return jwtUtil.createToken(userNm, SecurityAuthority.getUserAuthority(), expiredTerm);
    }
}

```

위의 코드를 아래처럼 변경해보았다.

ChatGPT의 도움을 받았다.

아니, ChatGPT를 사용했다😅

@Import는 [StackOverFlow](https://stackoverflow.com/questions/59871209/how-to-integrate-open-api-3-with-spring-project-not-spring-boot-using-springdo/59880655#59880655)에서 발췌하였다.

나와 같은 고민을 하고 있던 사용자가 있었고 [GitHub Issue](https://github.com/springdoc/springdoc-openapi/issues/2343)에도 등재돼있지만 공식 답변은 미흡해보였다.

그리고 ComponentScan을 달고 조져주었더니 얼추 됨

```java
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.responses.ApiResponse;
import io.swagger.v3.oas.models.responses.ApiResponses;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import java.time.Duration;
import java.util.List;
import java.util.Locale;
import org.apache.commons.lang3.StringUtils;
import org.springdoc.core.configuration.SpringDocConfiguration;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springdoc.core.customizers.OperationCustomizer;
import org.springdoc.core.models.GroupedOpenApi;
import org.springdoc.core.properties.SwaggerUiConfigProperties;
import org.springdoc.core.properties.SwaggerUiOAuthProperties;
import org.springdoc.webmvc.core.configuration.SpringDocWebMvcConfiguration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Swagger 설정.
 *
 * @author : glorial
 * @since : 1.0
 */
@Configuration
@ComponentScan(basePackages = {"org.springdoc", "kr.co.sample"})
@EnableWebMvc
@Import({SpringDocConfiguration.class,
    SpringDocWebMvcConfiguration.class,
    org.springdoc.webmvc.ui.SwaggerConfig.class,
    SwaggerUiConfigProperties.class,
    SwaggerUiOAuthProperties.class,
    JacksonAutoConfiguration.class})
public class TestSwaggerConfig implements WebMvcConfigurer {

    @Value("#{custom['swagger.use.yn'] ?: 'N'}")
    private String swaggerUseYn;

    @Autowired
    private JwtUtil jwtUtil;

    @Bean
    public GroupedOpenApi customImplementation() {
        return GroupedOpenApi.builder()
                             .group("glorial")
                             .pathsToMatch("/api/**")
                             .addOpenApiCustomizer(addOpenApiCustomizer())
                             .addOperationCustomizer(addHeaderCustomizer())
                             .packagesToScan("kr.co")
                             .build();
    }

    private OpenApiCustomizer addOpenApiCustomizer() {
        return openApi -> {
            openApi.info(new Info().title("glorial REST API Documentation")
                                   .description("glorial REST Api Documentation")
                                   .version("1.0.0")
                                   .contact(new Contact().name("glorial")
                                                         .url("https://www.glorial.co.kr")
                                                         .email("glorial@glorial.co.kr"))
                                   .license(new License().name("Apache 2.0")
                                                         .url("http://www.apache.org/licenses/LICENSE-2.0")));

            openApi.components(new Components()
                .addSecuritySchemes("bearerAuth", new SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("bearer")
                    .bearerFormat("JWT"))
                .addSecuritySchemes("basicScheme", new SecurityScheme()
                    .type(SecurityScheme.Type.HTTP)
                    .scheme("basic")));

            openApi.addSecurityItem(new SecurityRequirement()
                .addList("bearerAuth")
                .addList("basicScheme"));


            openApi.getPaths().values().forEach(pathItem -> pathItem.readOperations().forEach(operation -> {
                ApiResponses apiResponses = operation.getResponses();
                apiResponses.addApiResponse("500", new ApiResponse().description("500 ERROR"));
                apiResponses.addApiResponse("403", new ApiResponse().description("403 ERROR"));
                apiResponses.addApiResponse("401", new ApiResponse().description("401 ERROR"));
            }));
        };
    }

    @Bean
    public OperationCustomizer addHeaderCustomizer() {
        return (OperationCustomizer) (operation, handlerMethod) -> {
            operation.addParametersItem(new io.swagger.v3.oas.models.parameters.Parameter()
                .name(JwtUtil.HEADER_AUTHORIZATION)
                .in("header")
                .schema(new io.swagger.v3.oas.models.media.StringSchema())
                .required(true)
                .example(JwtUtil.TOKEN_TYPE_BEARER + " " + createSwaggerToken()));

            operation.addParametersItem(new io.swagger.v3.oas.models.parameters.Parameter()
                .name(HttpHeaders.CONTENT_TYPE)
                .in("header")
                .schema(new io.swagger.v3.oas.models.media.StringSchema())
                .required(true)
                .example(MediaType.APPLICATION_JSON_VALUE));

            operation.addParametersItem(new io.swagger.v3.oas.models.parameters.Parameter()
                .name(HttpHeaders.ACCEPT_LANGUAGE)
                .in("header")
                .schema(new io.swagger.v3.oas.models.media.StringSchema())
                .required(true)
                .example(Locale.KOREAN.toString()));

            operation.addParametersItem(new io.swagger.v3.oas.models.parameters.Parameter()
                .name(JwtUtil.HEADER_X_CLIENT_ID)
                .in("header")
                .schema(new io.swagger.v3.oas.models.media.StringSchema())
                .required(true)
                .example("swaggertest"));

            return operation;
        };
    }

    private String createSwaggerToken() {
        if (!"Y".equals(swaggerUseYn)) {
            return StringUtils.EMPTY;
        }

        String userNm = "admin";
        long expiredTerm = Duration.ofDays(5).toMillis();  // 5일
        return jwtUtil.createToken(userNm, SecurityAuthority.getUserAuthority(), expiredTerm);
    }
}
```

### 4. 우선 Class 오류가 사라지자 냅다 서버를 띄워보았다.

서버 구동은 되었지만 swagger-ui/index.html 에 접속하니 오류가 발생했다.

![refs-errors](/images/2025-02-27-Springdoc/2025-03-03-14-33-55.png)

보통 @Operation에 Content를 직접 지정하라고 하는데

[여기](https://kdev.ing/springdoc-openapi-ui/#Could-not-resolve-pointer-components-schemas-XXX-does-not-exist-in-document)서 보았는데 저 오류는 인증 스키마 이외에 **요청과 응답에 대한 스키마 클래스가 포함되지 않아** 발생되는 오류라 하였다.

`new Components`가 아니라 `getComponents`가 핵심이다.

그리고 한가지 SpringFox와 달라진 점은 Authorization이 강제로 주입되지 않는다는 것이었다.

대신 example에 token이 보여지게 하여 복사-붙여넣기 신공으로 로그인을 할 수 있었다.

```java
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.responses.ApiResponse;
import io.swagger.v3.oas.models.responses.ApiResponses;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import java.time.Duration;
import java.util.Locale;
import org.apache.commons.lang3.StringUtils;
import org.springdoc.core.configuration.SpringDocConfiguration;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springdoc.core.customizers.OperationCustomizer;
import org.springdoc.core.models.GroupedOpenApi;
import org.springdoc.core.properties.SwaggerUiConfigProperties;
import org.springdoc.core.properties.SwaggerUiOAuthProperties;
import org.springdoc.webmvc.core.configuration.SpringDocWebMvcConfiguration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Swagger 설정.
 *
 * @author : glorial
 * @since : 1.0
 */
@Configuration
@ComponentScan(basePackages = {"org.springdoc", "kr.co.sample"})
@EnableWebMvc
@Import({SpringDocConfiguration.class,
    SpringDocWebMvcConfiguration.class,
    org.springdoc.webmvc.ui.SwaggerConfig.class,
    SwaggerUiConfigProperties.class,
    SwaggerUiOAuthProperties.class,
    JacksonAutoConfiguration.class})
public class TestSwaggerConfig implements WebMvcConfigurer {

    @Value("#{custom['swagger.use.yn'] ?: 'N'}")
    private String swaggerUseYn;

    @Autowired
    private JwtUtil jwtUtil;

    @Bean
    public GroupedOpenApi customImplementation() {
        return GroupedOpenApi.builder()
                             .group("glorial")
                             .pathsToMatch("/api/**")
                             .addOpenApiCustomizer(addOpenApiCustomizer())
                             .addOperationCustomizer(addHeaderCustomizer())
                             .packagesToScan("kr.co")
                             .build();
    }

    private OpenApiCustomizer addOpenApiCustomizer() {
        return openApi -> {
            openApi.info(new Info().title("glorial REST API Documentation")
                                   .description("glorial REST Api Documentation")
                                   .version("1.0.0")
                                   .contact(new Contact().name("glorial")
                                                         .url("https://www.glorial.co.kr")
                                                         .email("glorial@glorial.co.kr"))
                                   .license(new License().name("Apache 2.0")
                                                         .url("http://www.apache.org/licenses/LICENSE-2.0")));

            openApi.addSecurityItem(new SecurityRequirement().addList("bearerAuth"));

            openApi.getComponents().addSecuritySchemes("bearerAuth", new SecurityScheme()
                .type(SecurityScheme.Type.APIKEY)
                .scheme("bearer")
                .bearerFormat("JWT")
                .in(SecurityScheme.In.HEADER)
                .name(HttpHeaders.AUTHORIZATION)
                .description((JwtUtil.TOKEN_TYPE_BEARER + " " + createSwaggerToken())));

            openApi.getPaths().values().forEach(pathItem -> pathItem.readOperations().forEach(operation -> {
                ApiResponses apiResponses = operation.getResponses();
                apiResponses.addApiResponse("500", new ApiResponse().description("500 ERROR"));
                apiResponses.addApiResponse("403", new ApiResponse().description("403 ERROR"));
                apiResponses.addApiResponse("401", new ApiResponse().description("401 ERROR"));
            }));
        };
    }

    @Bean
    public OperationCustomizer addHeaderCustomizer() {
        return (operation, handlerMethod) -> {
            operation.addParametersItem(new io.swagger.v3.oas.models.parameters.Parameter()
                .name(HttpHeaders.ACCEPT_LANGUAGE)
                .in("header")
                .schema(new io.swagger.v3.oas.models.media.StringSchema())
                .required(true)
                .example(Locale.KOREAN.toString()));

            operation.addParametersItem(new io.swagger.v3.oas.models.parameters.Parameter()
                .name(JwtUtil.HEADER_X_CLIENT_ID)
                .in("header")
                .schema(new io.swagger.v3.oas.models.media.StringSchema())
                .required(true)
                .example("swaggertest"));

            return operation;
        };
    }

    private String createSwaggerToken() {
        if (!"Y".equals(swaggerUseYn)) {
            return StringUtils.EMPTY;
        }

        String userNm = "admin";
        long expiredTerm = Duration.ofDays(5).toMillis();  // 5일
        return jwtUtil.createToken(userNm, SecurityAuthority.getUserAuthority(), expiredTerm);
    }
}
```

### 5. JWT Token 인증 시 Exception 발생

`jsonwebtoken` 0.9.1을 사용중이었는데 이게 Spring6와 호환이 되지 않았다.

Servelt 4.0에서만 동작하는 버전이다 보니 업그레이드가 필요했다.

대대적으로 사용법이 바뀌어 하나씩 적용했다.

#### dependency 주입

```xml
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.6</version>
</dependency>
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId> <!-- or jjwt-gson if Gson is preferred -->
    <version>0.12.6</version>
    <exclusions>
        <exclusion> <!-- 이건 내가 사용하는 dependency와 충돌나서 제거 함 -->
            <artifactId>jackson-databind</artifactId>
            <groupId>com.fasterxml.jackson.core</groupId>
        </exclusion>
    </exclusions>
</dependency>
```

#### SecretKey 생성 변경

SecretKeySpec이 아닌 SecretKey를 직접 생성하는 방식으로 변경 되었다.

이거와 별개로 DatatypeConverter를 Decoders로 교체했다.

```java
private SecretKeySpec getSignKey() {
    return new SecretKeySpec(DatatypeConverter.parseBase64Binary(secretKey), SignatureAlgorithm.HS256.getJcaName());
}
```

```java
private SecretKey getSignKey() {
    return Keys.hmacShaKeyFor(Decoders.BASE64URL.decode(secretKey));
}
```

#### token 생성 method 변경

buider메소드 명칭이 변경되었다.

```java
return Jwts.builder()
            .setSubject(userNm)
            .setIssuedAt(issuedTime)
            .setExpiration(expiredTime)
            .signWith(SignatureAlgorithm.HS256, getSignKey())
            .claim(GRANTED_AUTHORITIES, authorities)
            .claim(USER_INFO, userNm)
            .compact();
```

```java
return Jwts.builder().subject(userNm).issuedAt(issuedTime).expiration(expiredTime).signWith(getSignKey())
        .claim(GRANTED_AUTHORITIES, authorities)
        .claim(USER_INFO, userNm)
        .compact();
```

#### token 검증 method 변경

builder메소드 명칭, 순서가 변경되었다.

```java
return Jwts.parser()
            .setSigningKey(getSignKey())
            .parseClaimsJws(token)
            .getBody();
```

```java
return Jwts.parser()
        .verifyWith(getSignKey())
        .build()
        .parseSignedClaims(token).getPayload();
```

### 6. 이제 API를 조회해보자

이제 됐겠지?

응 안됨 ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ

- `readOnly`  
  readOnly로 명시했던 property들이 그대로 노출되고 있었음.  
  `readOnly`는 deprecated되어서 그런가 위에서 명시한대로 access로 일일이 변경해주었다.

- `PathVariable`  
  예전엔 자동으로 보였던 PathVariable들이 나오지 않았음.  
  `PathVariable`은 메소드 상단에 `Parameter`로 조져주니 잘 나왔음.  
   근데 일부는 메소드 상단에 명시하지 않아도 잘 나옴. 어쩌라는건지 모르겠음.  

- `LocalDate`, `LocalDateTime` 형식  
  일일이 다른 방식으로 변경해주었음

- `ModelAttribute`  
  기존엔 생략해도 잘 나오던 DTO의 Property들이 안나옴 그냥 안나옴  
  그래서 `ParameterObject`라는 Annotation을 추가로 지정 함

### 7. Missing Content-Type

이제 얼추 되가지? 이쯤 했으면 그만하자....

응 안돼 더해야 해 ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ

Content-Type을 안넣어주네? 

이게 뭔가 규약에 맞게 한거라는데 get,delete일 때는 Content-Type을 안보내준다는거임...

도대체 왜 그러냐 Postman은 되는데 왜 너넨 안됨? 해도 응 안해줄꺼야! 의미 없어! 라고 해버리니

뭐....

암튼 어쨌든 진짜로 필요하다면 이건 operation에 RequestBody(SpringDoc용, Spring RequestBody 아님)을 추가해주래 [출처](https://github.com/springdoc/springdoc-openapi/issues/657#issuecomment-625891941)

그래서 어떻게했다?

모든 Oepration의 Body를 체크해서 없으면 RequestBody를 넣게 조져주었지

OK, Let's go.

```java
openApi.getPaths().values().forEach(pathItem -> {
    pathItem.readOperations().forEach(operation -> {
        operation.addParametersItem(new Parameter()
            .name("Content-Type")
            .in("header")
            .required(true)
            .schema(new io.swagger.v3.oas.models.media.Schema<>().type("string").example("application/json"))
        );
    });
});
```

### 8. API Group으로 나누기

이제 머 그럭저럭 잘 돌아감

하지만 개인적으로 Group으로 나누고 싶었음

그냥 아무생각없이 `GroupedOpenApi`를 여러개 생성하면 되겠지? 

난 두개 필요하니까 OK 두개!!

```java
@Bean
public GroupedOpenApi sampleGroupImplementation() {
    return GroupedOpenApi.builder()
                          .group("sample")
                          .pathsToMatch("/api/**")
                          .addOpenApiCustomizer(addOpenApiCustomizer())
                          .addOperationCustomizer(addHeaderCustomizer())
                          .packagesToScan("kr.co.sample")
                          .build();
}

@Bean
public GroupedOpenApi bizImplementation() {
    return GroupedOpenApi.builder()
                          .group("biz")
                          .pathsToMatch("/api/**")
                          .addOpenApiCustomizer(addOpenApiCustomizer())
                          .addOperationCustomizer(addHeaderCustomizer())
                          .packagesToScan("kr.co.biz")
                          .build();
}
```

왜 계속 뭘 어떻게해도 맨 마지막꺼만 적용되는거냐고!!!! 😭😭😭😭😭😭😭😭😭

진짜 적당히 하자 쫌....내가 문서에서 놓친게 있나?

Group으로 나누려면 별도의 Configuration을 추가해주어야 하고

GroupConfig 클래스를 별도로 생성해줘야 했음

하아.....이것때문에 Config 클래스만 3개로 늘었네......

`SwaggerConfig.java` 를 3개의 클래스로 쪼개주었다.

**WebMvcConfig.java**
```java
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@EnableWebMvc
public class WebMvcConfig implements WebMvcConfigurer {

}
```

**SwaggerConfig.java**
```java
import org.springdoc.core.configuration.SpringDocConfiguration;
import org.springdoc.core.properties.SpringDocConfigProperties;
import org.springdoc.core.properties.SwaggerUiConfigParameters;
import org.springdoc.core.properties.SwaggerUiConfigProperties;
import org.springdoc.core.properties.SwaggerUiOAuthProperties;
import org.springdoc.webmvc.core.configuration.MultipleOpenApiSupportConfiguration;
import org.springdoc.webmvc.core.configuration.SpringDocWebMvcConfiguration;
import org.springdoc.webmvc.ui.SwaggerConfig;
import org.springframework.boot.autoconfigure.jackson.JacksonAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Configuration
@ComponentScan(basePackages = {"org.springdoc", "kr.co.sample", "kr.co.biz"}) //Package 추가
@Import({SpringDocConfigProperties.class,
    MultipleOpenApiSupportConfiguration.class,
    SpringDocConfiguration.class, SpringDocWebMvcConfiguration.class,
    SwaggerUiConfigParameters.class, SwaggerUiConfigProperties.class,
    SwaggerUiOAuthProperties.class,
    SwaggerConfig.class, SwaggerGroupsConfig.class, //SwaggerGroupConfig 가 추가
    JacksonAutoConfiguration.class})
public class TestSwaggerConfig {

}
```

**SwaggerGroupConfig.java**
```java
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.media.Content;
import io.swagger.v3.oas.models.media.MediaType;
import io.swagger.v3.oas.models.media.StringSchema;
import io.swagger.v3.oas.models.parameters.Parameter;
import io.swagger.v3.oas.models.parameters.RequestBody;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import java.time.Duration;
import java.util.Locale;
import org.apache.commons.lang3.StringUtils;
import org.springdoc.core.customizers.OpenApiCustomizer;
import org.springdoc.core.customizers.OperationCustomizer;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpHeaders;

@Configuration
public class SwaggerGroupsConfig {
    @Value("#{custom['swagger.use.yn'] ?: 'N'}")
    private String swaggerUseYn;

    @Autowired
    private JwtUtil jwtUtil;

    @Bean
    public GroupedOpenApi sampleImplementation() {
        return GroupedOpenApi.builder()
                             .group("sample")
                             .packagesToScan("kr.co.sample")
                             .addOpenApiCustomizer(addOpenApiCustomizer())
                             .addOperationCustomizer(addHeaderCustomizer())
                             .build();
    }

    @Bean
    public GroupedOpenApi bizImplementation() {
        return GroupedOpenApi.builder()
                             .group("biz")
                             .packagesToScan("kr.co.biz")
                             .addOpenApiCustomizer(addOpenApiCustomizer())
                             .addOperationCustomizer(addHeaderCustomizer())
                             .build();
    }

    private OpenApiCustomizer addOpenApiCustomizer() {
        return openApi -> {
            openApi.info(new Info().title("glorial REST API Documentation")
                                   .description("glorial REST Api Documentation")
                                   .version("1.0.0")
                                   .contact(new Contact().name("glorial")
                                                         .url("https://www.glorial.co.kr")
                                                         .email("glorial@glorial.co.kr"))
                                   .license(new License().name("Apache 2.0")
                                                         .url("http://www.apache.org/licenses/LICENSE-2.0")));

            openApi.addSecurityItem(new SecurityRequirement().addList("bearerAuth"));

            openApi.getComponents().addSecuritySchemes("bearerAuth", new SecurityScheme()
                .type(SecurityScheme.Type.APIKEY)
                .scheme("bearer")
                .bearerFormat("JWT")
                .in(SecurityScheme.In.HEADER)
                .name(HttpHeaders.AUTHORIZATION)
                .description((JwtUtil.TOKEN_TYPE_BEARER + " " + createSwaggerToken())));

            openApi.getPaths().values().forEach(pathItem -> {
                pathItem.readOperations().forEach(operation -> {
                    operation.addParametersItem(new Parameter()
                        .name("Content-Type")
                        .in("header")
                        .required(true)
                        .schema(new io.swagger.v3.oas.models.media.Schema<>().type("string").example("application/json"))
                    );
                });
            });
        };
    }

    @Bean
    public OperationCustomizer addHeaderCustomizer() {
        RequestBody requestBody = new RequestBody().content(new Content().addMediaType(org.springframework.http.MediaType.APPLICATION_JSON_VALUE, new MediaType()));

        return (operation, handlerMethod) -> {
            operation.addParametersItem(new Parameter()
                .name(HttpHeaders.ACCEPT_LANGUAGE)
                .in("header")
                .schema(new StringSchema())
                .required(true)
                .example(Locale.KOREAN.toString()));

            operation.addParametersItem(new Parameter()
                .name(JwtUtil.HEADER_X_CLIENT_ID)
                .in("header")
                .schema(new StringSchema())
                .required(true)
                .example("swaggertest"));

            if (operation.getRequestBody() == null) {
                operation.setRequestBody(requestBody);
            }

            return operation;
        };
    }

    private String createSwaggerToken() {
        if (!"Y".equals(swaggerUseYn)) {
            return StringUtils.EMPTY;
        }

        String userNm = "admin";
        long expiredTerm = Duration.ofDays(5).toMillis();  // 5일
        return jwtUtil.createToken(userNm, SecurityAuthority.getUserAuthority(), expiredTerm);
    }
}
```

## 최종결론

여러분 웬만하면 `SpringBoot` 쓰세요

이젠 MVC는 쓸 수 없어요

저야 호환성 때문에 어쩔 수 없이 멱살잡고 끌고가는 중인데 3rdParty들이 호환이 안되요


## 근데 아직 한발 더 남았다

첨부파일 잘 되는지 해봐야 함

보아하니 Multipart일 때도 이짓거리 해야 할것 같은데?! ㅋㅋㅋㅋㅋㅋㅋㅋ


# 참고URL

- https://springdoc.org/faq.html

- https://github.com/springdoc/springdoc-openapi-demos/blob/master/demo-spring-boot-3-webmvc/src/main/java/org/springdoc/demo/app2/model/Pet.java

- https://stackoverflow.com/questions/59871209/how-to-integrate-open-api-3-with-spring-project-not-spring-boot-using-springdo

- https://github.com/springdoc/springdoc-openapi/issues/250

- https://github.com/essentialprogramming/undertow-spring-web/blob/master/src/main/java/com/undertow/standalone/UndertowServer.java

- https://github.com/springdoc/springdoc-openapi/issues/841

- https://github.com/springdoc/springdoc-openapi/issues/657

- https://velog.io/@numerical43/java-spring-swagger-springdoc-openapi

- https://velog.io/@jh9/jjwt

- https://stackoverflow.com/questions/59560763/default-value-for-accept-header-using-springdoc-openapi

- https://jeonyoungho.github.io/posts/Open-API-3.0-Swagger-v3-%EC%83%81%EC%84%B8%EC%84%A4%EC%A0%95/

- https://sjh9708.tistory.com/169

- https://blaxsior-repository.tistory.com/287

- https://yeonyeon.tistory.com/322, https://yeonyeon.tistory.com/324  *최고입니다*

- https://blog.naver.com/kisukim94/223773992123 *HTTP Method별 유형*

- https://colabear754.tistory.com/99 *Fox -> Doc 전환*

- https://kdev.ing/springdoc-openapi-ui/ *Outstanding!!*

- https://data-make.tistory.com/550

- https://stackoverflow.com/questions/63627462/swagger-openapi-3-0-springdoc-groupedopenapi-not-working-in-spring-mvc

- https://stackoverflow.com/questions/75967916/configure-groups-into-springdoc-openapi

- https://stackoverflow.com/questions/75136114/springdoc-openapi-3-0-swagger-groupedopenapi-not-working-in-spring-mvc

- https://tg360.tistory.com/entry/Springdoc-openapi%EB%A5%BC-%ED%99%9C%EC%9A%A9%ED%95%9C-Spring-Boot-%EA%B8%B0%EB%B0%98-API%EC%9D%98-%EB%AC%B8%EC%84%9C-%EC%9E%90%EB%8F%99%ED%99%94
