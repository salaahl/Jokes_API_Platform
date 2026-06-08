<?php

namespace App\Controller\Nutriverif;

use Psr\Log\LoggerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;

class NutriverifController extends AbstractController
{
    private HttpClientInterface $httpClient;
    private LoggerInterface $logger;

    public function __construct(HttpClientInterface $httpClient, LoggerInterface $logger)
    {
        $this->httpClient = $httpClient;
        $this->logger = $logger;
    }

    #[Route('/search-products', name: 'search_products', methods: ['POST'])]
    public function search(Request $request): JsonResponse
    {
        try {
            $data = $request->toArray();
            $url = $data['url'] ?? null;
            $method = strtoupper($data['method'] ?? 'GET');

            $incomingBody = $data['body'] ?? '';

            if (!isset($url)) {
                $this->logger->warning('NutriVerif: Tentative d\'appel sans paramètre "url".');
                return $this->json(
                    ['error' => 'Le paramètre "url" est requis.'],
                    Response::HTTP_BAD_REQUEST
                );
            }

            $payloadParams = [];
            parse_str($incomingBody, $payloadParams);

            $payloadParams['user_id'] = $_ENV['OFF_USERNAME'] ?? '';
            $payloadParams['password'] = $_ENV['OFF_PASSWORD'] ?? '';

            $options = [
                'headers' => [
                    'User-Agent' => 'NutriVérif/1.0 (sokhona.salaha@gmail.com)',
                ],
            ];

            if ('POST' === $method) {
                $options['body'] = $payloadParams;
            } else {
                $options['query'] = $payloadParams;
            }

            $response = $this->httpClient->request($method, $url, $options);

            $statusCode = $response->getStatusCode();

            if (200 !== $statusCode) {
                $debugParams = $payloadParams;

                if (isset($debugParams['password'])) {
                    $debugParams['password'] = '******';
                }

                $this->logger->error(
                    "NutriVerif: OpenFoodFacts a renvoyé un code " . $statusCode .
                        " pour l'URL : " . $url .
                        " | Paramètres POST envoyés : " . json_encode($debugParams)
                );

                return $this->json(
                    ['error' => 'Erreur lors de l’appel à OpenFoodFacts.', 'status' => $statusCode],
                    Response::HTTP_BAD_GATEWAY
                );
            }

            return $this->json($response->toArray());
        } catch (\Exception $e) {
            $this->logger->critical('NutriVerif: Crash du contrôleur ! Message : ' . $e->getMessage(), [
                'exception' => $e
            ]);

            return $this->json(
                ['error' => 'Une erreur interne est survenue.', 'details' => $e->getMessage()],
                Response::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}
